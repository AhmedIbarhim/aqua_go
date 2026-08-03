import 'package:aqua_go/core/utils/saudi_wire_format.dart';
import 'package:aqua_go/features/gifts/presentation/controllers/send_gift_state.dart';
import 'package:aqua_go/generated/codegen_loader.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AQG-392 in the gift flow, which p1 does not have and the original sweep
/// therefore missed.
///
/// The purchase path used to recover the delivery time by PARSING the time
/// picker's label — `"09:00 PM".split(' ')`, then `parts[1] == 'PM'`. Arabic
/// emits `9:00 م`, never `PM`, so the `+12` was skipped and a 9 PM gift was
/// scheduled for 09:00 — under the app's DEFAULT language. The picked
/// [TimeOfDay] is now carried structurally from the picker to
/// `scheduledDeliveryAt`, so no label sits on the wire path at all.
void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  tearDown(() {
    Intl.defaultLocale = null;
    Intl.systemLocale = 'en_US';
  });

  /// Mounts the app's localization scaffolding and hands back the
  /// [MaterialLocalizations] the time picker would format its label with.
  Future<MaterialLocalizations> materialLocalizations(
    WidgetTester tester, {
    required String locale,
  }) async {
    late MaterialLocalizations localizations;
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ar'),
        startLocale: Locale(locale),
        assetLoader: const CodegenLoader(),
        child: Builder(
          builder: (context) => MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: Builder(
              builder: (inner) {
                localizations = MaterialLocalizations.of(inner);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return localizations;
  }

  /// The deleted algorithm, kept HERE as a counterexample so the label data it
  /// depended on stays under test. Returns null where it used to throw — both
  /// outcomes are corruption.
  int? legacyHourFrom(String label) {
    try {
      final parts = label.split(' ');
      if (parts.length != 2) return null;
      int hour = int.parse(parts[0].split(':')[0]);
      final isPm = parts[1].toUpperCase() == 'PM';
      if (isPm && hour < 12) {
        hour += 12;
      } else if (!isPm && hour == 12) {
        hour = 0;
      }
      return hour;
    } catch (_) {
      return null;
    }
  }

  /// A 9 PM delivery on 2026-07-24 — the pick, structurally.
  SendGiftState scheduled(TimeOfDay time) => SendGiftState(
    deliveryType: 'SCHEDULED',
    scheduledDate: DateTime(2026, 7, 24),
    scheduledTime: time,
  );

  group('the gift delivery time reaches the wire as it was picked', () {
    const ninePm = TimeOfDay(hour: 21, minute: 0);

    testWidgets('the picked wall clock survives every locale', (tester) async {
      await materialLocalizations(tester, locale: 'ar');

      // App language and handset language are varied together: neither may
      // reach the wire value.
      for (final locale in const ['ar', 'en', 'bn']) {
        Intl.systemLocale = locale;
        Intl.defaultLocale = locale;

        expect(
          toWireDateTime(scheduled(ninePm).scheduledDeliveryAt!),
          '2026-07-24T21:00:00',
          reason: 'locale $locale',
        );
      }
    });

    testWidgets('midnight stays midnight instead of becoming noon', (
      tester,
    ) async {
      await materialLocalizations(tester, locale: 'ar');

      // `12:00 AM` walked the old code's `hour == 12` branch, which is the one
      // case it got right; `12:00 PM` is the one it did not.
      expect(
        toWireDateTime(
          scheduled(const TimeOfDay(hour: 0, minute: 0)).scheduledDeliveryAt!,
        ),
        '2026-07-24T00:00:00',
      );
      expect(
        toWireDateTime(
          scheduled(const TimeOfDay(hour: 12, minute: 0)).scheduledDeliveryAt!,
        ),
        '2026-07-24T12:00:00',
      );
    });

    testWidgets('the wire value is ASCII under a ZERODIGIT handset', (
      tester,
    ) async {
      await materialLocalizations(tester, locale: 'ar');

      Intl.systemLocale = 'bn';
      Intl.defaultLocale = 'bn';

      expect(
        toWireDateTime(scheduled(ninePm).scheduledDeliveryAt!),
        matches(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$')),
      );
    });

    testWidgets('no delivery instant until BOTH pickers have been used', (
      tester,
    ) async {
      await materialLocalizations(tester, locale: 'ar');

      expect(
        const SendGiftState(
          deliveryType: 'SCHEDULED',
          scheduledTime: ninePm,
        ).scheduledDeliveryAt,
        isNull,
      );
      expect(
        SendGiftState(
          deliveryType: 'SCHEDULED',
          scheduledDate: DateTime(2026, 7, 24),
        ).scheduledDeliveryAt,
        isNull,
      );
    });
  });

  group('why the picker label can never be parsed back', () {
    const ninePm = TimeOfDay(hour: 21, minute: 0);

    testWidgets('the Arabic label carries م, so the old parser read 09:00', (
      tester,
    ) async {
      final ar = await materialLocalizations(tester, locale: 'ar');
      final label = ar.formatTimeOfDay(ninePm);

      expect(label, '9:00 م');
      expect(label, isNot(contains('PM')));
      // The corruption itself, against real localization data: 9 PM read back
      // as 09:00. Arabic is the app's DEFAULT language, so this was the
      // ordinary path, not an edge case.
      expect(legacyHourFrom(label), 9);
      // While the value the flow now carries is simply the value picked.
      expect(scheduled(ninePm).scheduledDeliveryAt!.hour, 21);
    });

    testWidgets('English is the only case the old parser ever got right', (
      tester,
    ) async {
      final en = await materialLocalizations(tester, locale: 'en');

      // Which is why this shipped: the language the code was written in works.
      expect(legacyHourFrom(en.formatTimeOfDay(ninePm)), 21);
    });
  });
}
