import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/promo_summary_harness.dart';

/// UCC16 — the applied promo code's lifecycle across the booking summary.
///
/// Note on strings: these tests assert on the localization KEYS the screen
/// renders, not on English copy. `tr(context: context)` resolves to the key
/// itself under the test harness, which makes the assertions about WHICH
/// message fires — the behaviour under test — instead of about wording.
void main() {
  const promoCode = 'WELCOME15';

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await CacheClient.init();
    await EasyLocalization.ensureInitialized();
    await loadTranslations();
  });

  testWidgets('an applied code survives leaving and re-entering the summary', (
    tester,
  ) async {
    final repo = RecordingBookingRepo();
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);

    await pumpSummary(tester, cubit);
    await applyPromo(tester, promoCode);
    expect(repo.quoteCalls, [null, promoCode]);
    expect(cubit.state.appliedPromoCode, promoCode);

    // Pop back to the details screen and come forward again: the route's State
    // is destroyed, the cubit is not.
    await remountSummary(tester, cubit);

    expect(
      repo.quoteCalls,
      [null, promoCode, promoCode],
      reason:
          're-entering the summary must re-quote WITH the code the customer '
          'already applied, not silently at the undiscounted price',
    );
    expect(cubit.state.appliedPromoCode, promoCode);
    expect(cubit.state.quote!.breakdown!.grossMinor, grossWithPromoMinor);
    // The applied chip is on screen, not the "add a code" prompt.
    expect(find.byIcon(Icons.discount_outlined), findsNothing);
    expect(find.textContaining(promoCode), findsOneWidget);
  });

  testWidgets(
    'a code that stops being valid is dropped, with the reason, instead of '
    'repeating the same rejection forever',
    (tester) async {
      late final RecordingBookingRepo repo;
      // The code applies cleanly, then stops being applicable — exactly what a
      // usage cap consumed by another customer between quotes looks like.
      repo = RecordingBookingRepo(
        quoteFailure: (code) => code != null && repo.quoteCalls.length >= 3
            ? const ServerFailure(
                'This promo code is not available to you.',
                type: FailureType.validation,
              )
            : null,
      );
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      await applyPromo(tester, promoCode);
      expect(cubit.state.appliedPromoCode, promoCode);

      // Confirm: the quote has expired, so the screen re-quotes first — and the
      // code is refused this time.
      await tapConfirm(tester);

      expect(
        repo.quoteCalls,
        [null, promoCode, promoCode, null],
        reason:
            'the refused code must be dropped and the order re-quoted without '
            'it, so the customer has a total they can actually pay',
      );
      expect(
        cubit.state.appliedPromoCode,
        isNull,
        reason: 'a code the backend refused must not stay applied',
      );
      expect(
        cubit.state.quote!.breakdown!.grossMinor,
        grossWithoutPromoMinor,
        reason: 'the displayed total must be the one without the discount',
      );
      expect(
        repo.paymentInitCalls,
        0,
        reason:
            'the customer must review the changed total before being charged',
      );
      // They are told the code went and why.
      expect(
        find.textContaining('This promo code is not available to you.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('bookings.promo_code_removed'),
        findsOneWidget,
      );

      // Tapping Confirm again is a different, actionable outcome: no code, no
      // repeated rejection — the charge is attempted.
      await tapConfirm(tester);
      expect(repo.quoteCalls, [null, promoCode, promoCode, null, null]);
      expect(repo.paymentInitCalls, 1);
    },
  );

  testWidgets(
    'an applied code survives an add-on change made back on the details screen',
    (tester) async {
      final repo = RecordingBookingRepo();
      final cubit = buildCubit(repo, withService: serviceWithAddOn);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      await applyPromo(tester, promoCode);
      expect(cubit.state.appliedPromoCode, promoCode);

      // Back to the details screen, where the customer adds an add-on. That
      // re-prices the order — WITH the code they already applied, or the
      // discount vanishes without a word and the applied chip on the summary
      // starts describing a quote that no longer carries it.
      await pumpDetails(tester, cubit);
      await tester.tap(find.text('تلميع الإطارات'));
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);

      expect(
        repo.quoteCalls.last,
        promoCode,
        reason: 'the add-on re-quote must carry the applied promo code',
      );
      expect(cubit.state.appliedPromoCode, promoCode);
      expect(cubit.state.quote!.breakdown!.grossMinor, grossWithPromoMinor);
    },
  );
}
