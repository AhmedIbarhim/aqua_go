import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_go/features/offers/domain/pending_promo_code.dart';
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
        quoteFailure: (code, _) => code != null && repo.quoteCalls.length >= 3
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
    'an applied code survives an add-on change made back on the details '
    'screen, WITHOUT that screen quoting the discount',
    (tester) async {
      final repo = RecordingBookingRepo();
      final cubit = buildCubit(repo, withService: serviceWithAddOn);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      await applyPromo(tester, promoCode);
      expect(cubit.state.appliedPromoCode, promoCode);

      // Back to the details screen, where the customer adds an add-on. That
      // re-prices the order — BARE, per the owner's ruling (plan §6.93): no
      // discount shows before the payment page, and this screen has no promo
      // affordance that could explain one. The code itself is untouched, so the
      // summary re-applies it the moment the customer moves forward.
      await pumpDetails(tester, cubit);
      await tester.tap(find.text('تلميع الإطارات'));
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);

      expect(
        repo.quoteCalls.last,
        isNull,
        reason: 'the add-on re-quote on details must carry no promo code',
      );
      expect(
        cubit.state.appliedPromoCode,
        promoCode,
        reason: 'the code is out of the quote, not out of the order',
      );
      expect(cubit.state.quote!.breakdown!.grossMinor, grossWithoutPromoMinor);
    },
  );

  testWidgets(
    'an offer that no longer applies still leaves the customer a payable total',
    (tester) async {
      // The offer was eligible when the feed rendered it and is not by the time
      // the customer taps through — its cap was consumed by a concurrent
      // booking (UCC23 A3 / BR-OFR-11). The server answers the same
      // `promo-not-recognised` it gives a garbage code; nothing in the copy
      // below claims to know which of those happened.
      const rejection = 'Code not recognised or expired';
      final repo = RecordingBookingRepo(
        quoteFailure: (_, offerId) => offerId == null
            ? null
            : const ServerFailure(rejection, type: FailureType.validation),
      );
      PendingPromoCode.instance.hold(offerId: 'offer-1', promoCode: promoCode);
      // Drain the single-shot slot so a failed test cannot leak a handoff into
      // the next one.
      addTearDown(PendingPromoCode.instance.takeHandoff);

      final cubit = buildCubit(repo);
      addTearDown(cubit.close);
      await pumpSummary(tester, cubit);

      expect(
        repo.offerCalls,
        ['offer-1', null],
        reason:
            'the offer is tried first, then the order is re-priced WITHOUT it '
            'so the customer has a total they can actually pay',
      );
      expect(cubit.state.appliedPromoCode, isNull);
      expect(
        cubit.state.quote!.breakdown!.grossMinor,
        grossWithoutPromoMinor,
        reason: 'UCC23 A3 — the discount is not granted, the total is unchanged',
      );
      // The rejection is raised once, by the cubit's failure state. Nothing
      // adds a second message on top of it.
      expect(find.textContaining(rejection), findsOneWidget);
      expect(
        find.textContaining('bookings.promo_code_removed'),
        findsNothing,
        reason: 'no code was ever applied, so none was removed',
      );
    },
  );
}
