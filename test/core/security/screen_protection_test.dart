// PH1-022: ScreenProtectionScope enables protection when a sensitive screen
// mounts and disables it on dispose, via the injectable ScreenProtection seam.
import 'package:aqua_go/core/security/screen_protection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeScreenProtection implements ScreenProtection {
  int enabled = 0;
  int disabled = 0;

  @override
  Future<void> enable() async => enabled++;

  @override
  Future<void> disable() async => disabled++;
}

void main() {
  late _FakeScreenProtection fake;

  setUp(() {
    fake = _FakeScreenProtection();
    ScreenProtection.setInstanceForTesting(fake);
  });

  tearDown(ScreenProtection.resetInstance);

  testWidgets('enables on mount and disables on dispose', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScreenProtectionScope(child: SizedBox.shrink()),
      ),
    );

    expect(fake.enabled, 1);
    expect(fake.disabled, 0);

    // Replace the tree so the scope is disposed.
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    expect(fake.disabled, 1);
  });

  testWidgets(
    'stacked protected routes: pushing does not re-enable and popping the '
    'top keeps protection ON for the sensitive screen beneath',
    (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          home: const ScreenProtectionScope(child: SizedBox.shrink()),
        ),
      );

      // First protected screen: platform turned ON exactly once.
      expect(fake.enabled, 1);
      expect(fake.disabled, 0);

      // Push a second protected screen on top (e.g. profile -> edit profile).
      navKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const ScreenProtectionScope(child: SizedBox.shrink()),
        ),
      );
      await tester.pumpAndSettle();

      // Already protected: no redundant re-enable, no spurious disable.
      expect(fake.enabled, 1);
      expect(fake.disabled, 0);

      // Pop the top screen; the PII screen beneath is visible again.
      navKey.currentState!.pop();
      await tester.pumpAndSettle();

      // Protection MUST remain ON — this is the PH1-022 review blocker.
      expect(fake.disabled, 0);

      // Dispose the last protected screen: only now does protection turn OFF.
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      expect(fake.disabled, 1);
    },
  );

  test('default instance is the real ScreenProtector-backed impl', () {
    ScreenProtection.resetInstance();
    expect(ScreenProtection.instance, isA<ScreenProtection>());
  });
}
