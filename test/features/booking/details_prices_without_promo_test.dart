import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/features/offers/domain/pending_promo_code.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/promo_summary_harness.dart';

/// The owner's ruling (plan §6.93): **no discount before the payment page.**
///
/// Taking an offer applies its code, and the booking-DETAILS screen used to
/// re-quote with it — so after the customer closed the summary, details sat
/// there showing a discounted total with nothing on screen explaining it. That
/// screen has no promo affordance at all.
///
/// Details now prices the bare selection. The split that makes this safe rather
/// than destructive is the one these tests pin: the code is out of the QUOTE and
/// still in the STATE, so the summary — the one screen that shows and explains
/// the discount — re-quotes with it and the customer is charged the price they
/// took the offer for. Clearing it on details instead would silently un-take the
/// offer and charge full price.
///
/// The total therefore steps DOWN entering the payment page and back UP on
/// return. That is the accepted consequence of the ruling, not a defect; the
/// summary's original → discount → total breakdown is what makes it legible.
void main() {
  const offerId = 'offer-1';

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await CacheClient.init();
    await EasyLocalization.ensureInitialized();
    await loadTranslations();
  });

  /// Arms the flow where the owner's report starts: the customer tapped "Use
  /// this code" on an offer, so the next summary mount consumes the handoff.
  /// The held code is display-only — the server resolves the offer's own code
  /// and echoes [offerResolvedPromoCode], which is what lands on the state.
  void takeOffer() {
    PendingPromoCode.instance.hold(offerId: offerId, promoCode: 'HELD');
    // Drain the single-shot slot so a failed test cannot leak a handoff into
    // the next one.
    addTearDown(PendingPromoCode.instance.takeHandoff);
  }

  testWidgets(
    'an offer taken on the offers surface leaves the details screen quoting '
    'BARE — no code, no offer id, undiscounted total',
    (tester) async {
      final repo = RecordingBookingRepo();
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      takeOffer();
      await pumpSummary(tester, cubit);

      // The offer is applied and the summary is showing the discounted total.
      expect(repo.offerCalls, [offerId]);
      expect(cubit.state.appliedPromoCode, offerResolvedPromoCode);
      expect(cubit.state.quote!.breakdown!.grossMinor, grossWithPromoMinor);

      // Close the payment page: back to booking details.
      await pumpDetails(tester, cubit);

      expect(
        repo.quoteCalls.last,
        isNull,
        reason: 'the details quote must carry no promo code',
      );
      expect(
        repo.offerCalls.last,
        isNull,
        reason: 'and no offer id — the discount does not apply before payment',
      );
      expect(
        cubit.state.quote!.breakdown!.grossMinor,
        grossWithoutPromoMinor,
        reason: 'details prices the selection as if no offer had been taken',
      );
      expect(
        find.text('115.00'),
        findsOneWidget,
        reason: 'the undiscounted total is what this screen shows',
      );
      expect(
        find.text('95.00'),
        findsNothing,
        reason: 'a discounted total here has nothing on screen explaining it',
      );
    },
  );

  testWidgets(
    'the offer the customer took survives the bare details quote IN STATE',
    (tester) async {
      final repo = RecordingBookingRepo();
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      takeOffer();
      await pumpSummary(tester, cubit);
      await pumpDetails(tester, cubit);

      // The bare quote came back carrying no code. Reading the applied promo
      // off THAT quote — which is what every other re-quote path does — would
      // clear both halves here, leaving the summary nothing to re-apply and the
      // customer paying full price for an offer they took.
      expect(
        cubit.state.appliedPromoCode,
        offerResolvedPromoCode,
        reason: 'quoting bare is a display choice, not a removal',
      );
      expect(
        cubit.state.appliedOfferId,
        offerId,
        reason: 'the offer attribution must reach the redemption row',
      );
    },
  );

  testWidgets(
    'moving forward to the payment page re-quotes WITH the offer and shows the '
    'discount',
    (tester) async {
      final repo = RecordingBookingRepo();
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      takeOffer();
      await pumpSummary(tester, cubit);
      await pumpDetails(tester, cubit);
      expect(repo.quoteCalls.last, isNull);

      // Forward again. The handoff is long drained, so this is the summary's
      // own re-quote off the applied state — and it is the whole reason the
      // code had to stay there.
      await remountSummary(tester, cubit);

      expect(
        repo.quoteCalls.last,
        offerResolvedPromoCode,
        reason: 'the payment page re-quotes with the code that is applied',
      );
      expect(
        repo.offerCalls.last,
        offerId,
        reason: 'and with the offer that produced it, for attribution',
      );
      expect(cubit.state.quote!.breakdown!.grossMinor, grossWithPromoMinor);

      // The three-value breakdown is what explains the step down — nothing else
      // is added to soften it.
      expect(find.text('115.00'), findsOneWidget);
      expect(find.text('-20.00'), findsOneWidget);
      expect(find.text('95.00'), findsOneWidget);
    },
  );

  testWidgets(
    'returning to details prices bare again, with the offer still applied',
    (tester) async {
      final repo = RecordingBookingRepo();
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      takeOffer();
      await pumpSummary(tester, cubit);
      await pumpDetails(tester, cubit);
      await remountSummary(tester, cubit);
      expect(cubit.state.quote!.breakdown!.grossMinor, grossWithPromoMinor);

      await pumpDetails(tester, cubit);

      expect(repo.quoteCalls.last, isNull);
      expect(repo.offerCalls.last, isNull);
      expect(
        cubit.state.quote!.breakdown!.grossMinor,
        grossWithoutPromoMinor,
        reason: 'the total steps back up — the accepted consequence, pinned '
            'so it cannot be "fixed" into leaking the discount backward',
      );
      expect(find.text('115.00'), findsOneWidget);
      expect(find.text('95.00'), findsNothing);
      expect(cubit.state.appliedPromoCode, offerResolvedPromoCode);
      expect(cubit.state.appliedOfferId, offerId);
    },
  );
}
