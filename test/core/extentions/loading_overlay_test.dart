import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:aqua_go/core/extentions/context_extentions/loading_extension.dart';
import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression cover for the blocking loading overlay.
///
/// Both halves of the overlay are deferred to post-frame callbacks, so a
/// show/hide pair that lands inside a single frame gap cancels the insert and
/// then still tries to remove the entry — which trips
/// "An OverlayEntry should be removed only once". Real HTTP always spans a
/// frame, which is the only reason this never bit production; a cached or
/// instantly-failing call closes the gap.
void main() {
  Widget harness(void Function(BuildContext) onReady) {
    return MaterialApp(
      theme: ThemeData(
        extensions: const <ThemeExtension<dynamic>>[lightAppColors],
      ),
      home: Builder(
        builder: (context) {
          return TextButton(
            onPressed: () => onReady(context),
            child: const Text('go'),
          );
        },
      ),
    );
  }

  testWidgets('show followed by hide in the same frame gap does not throw', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness((context) {
        context.showLoadingOverlay();
        context.hideLoadingOverlay();
      }),
    );

    await tester.tap(find.text('go'));
    // The post-frame callbacks both run on this pump: the insert opts out
    // because the entry is no longer current, so the removal must opt out too.
    await tester.pump();
    // Second frame — an entry inserted post-frame only paints on the next one.
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(CustomLoadingIndicator), findsNothing);
  });

  testWidgets('show then hide across frames still shows and clears the overlay', (
    tester,
  ) async {
    late BuildContext captured;
    await tester.pumpWidget(harness((context) => captured = context));

    await tester.tap(find.text('go'));
    await tester.pump();

    captured.showLoadingOverlay();
    await tester.pump();
    await tester.pump();
    expect(find.byType(CustomLoadingIndicator), findsOneWidget);

    captured.hideLoadingOverlay();
    await tester.pump();
    await tester.pump();
    expect(find.byType(CustomLoadingIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nested show calls only clear on the last hide', (tester) async {
    late BuildContext captured;
    await tester.pumpWidget(harness((context) => captured = context));

    await tester.tap(find.text('go'));
    await tester.pump();

    captured.showLoadingOverlay();
    captured.showLoadingOverlay();
    await tester.pump();
    await tester.pump();
    expect(find.byType(CustomLoadingIndicator), findsOneWidget);

    captured.hideLoadingOverlay();
    await tester.pump();
    await tester.pump();
    expect(find.byType(CustomLoadingIndicator), findsOneWidget);

    captured.hideLoadingOverlay();
    await tester.pump();
    await tester.pump();
    expect(find.byType(CustomLoadingIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('resetLoadingOverlay clears a counter leaked by a torn-down screen',
      (tester) async {
    // AQG-439. Two listeners raise the overlay, then the route stack is
    // wiped by a session teardown before either "else -> hide" leg runs.
    // The counter is process-global, so without a reset it never returns to
    // zero and the entry — which lives in the ROOT overlay and survives the
    // route removal — sits on the login page forever.
    late BuildContext captured;
    await tester.pumpWidget(harness((context) => captured = context));

    await tester.tap(find.text('go'));
    await tester.pump();

    captured.showLoadingOverlay();
    captured.showLoadingOverlay();
    await tester.pump();
    await tester.pump();
    expect(find.byType(CustomLoadingIndicator), findsOneWidget);

    resetLoadingOverlay();
    await tester.pump();
    await tester.pump();
    expect(find.byType(CustomLoadingIndicator), findsNothing);

    // And the next screen's overlay still works — the reset must not leave
    // the counter negative or the entry double-removed.
    captured.showLoadingOverlay();
    await tester.pump();
    await tester.pump();
    expect(find.byType(CustomLoadingIndicator), findsOneWidget);

    captured.hideLoadingOverlay();
    await tester.pump();
    await tester.pump();
    expect(find.byType(CustomLoadingIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
