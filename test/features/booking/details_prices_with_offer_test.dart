import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/offers/domain/pending_promo_code.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/promo_summary_harness.dart';

/// Owner decision D-4 — the ONE bounded override of plan §6.93.
///
/// §6.93 says no discount before the payment page, and it is right about the
/// case it was written for: a promo code applied AT PAYMENT makes the total
/// jump, and a details screen with no promo affordance cannot explain a number
/// that moved. A SERVICE offer is the opposite shape. Its price is known
/// BEFORE the flow starts — the customer tapped a card that said 35.00 — so
/// showing the list price here and the offer price two screens later would
/// CREATE the step-change §6.93 exists to avoid.
///
/// The override is therefore scoped to offer-driven bookings and carried by
/// data, not by a flag: the two figures ride `BookingFlowStartArgs` from the
/// offer card into `BookingState`, and a booking that did not start from an
/// offer has neither, so it takes the §6.93 path unchanged. Its sibling file
/// `details_prices_without_promo_test.dart` pins that half.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await CacheClient.init();
    await EasyLocalization.ensureInitialized();
    await loadTranslations();
  });

  testWidgets(
    'a SERVICE offer shows its price on details, with the list price struck '
    'through',
    (tester) async {
      final repo = RecordingBookingRepo();
      final cubit = buildCubit(
        repo,
        offerListPriceMinor: 17500,
        offerTargetPriceMinor: 3500,
      );
      addTearDown(cubit.close);

      await pumpDetails(tester, cubit);

      expect(
        find.text('35.00'),
        findsOneWidget,
        reason: 'the price the customer tapped is the price they see here',
      );
      expect(
        find.text('175.00'),
        findsOneWidget,
        reason: 'struck through, so the saving is legible without arithmetic',
      );
      // Both figures come off the offer, never off the quote — the details
      // quote is deliberately bare, so its 115.00 would be the wrong number in
      // both directions.
      expect(find.text('115.00'), findsNothing);

      final struck = tester.widget<Text>(find.text('175.00'));
      expect(struck.style?.decoration, TextDecoration.lineThrough);
    },
  );

  testWidgets(
    'a SHORTCUT offer shows the list price only — 0 is no deal, not a free wash',
    (tester) async {
      // A SERVICE offer may carry no target at all. It is then a pure
      // deep-link, and the details screen must price it exactly as an
      // offer-less booking: off the quote.
      final repo = RecordingBookingRepo();
      final cubit = buildCubit(repo, offerListPriceMinor: 17500);
      addTearDown(cubit.close);

      await pumpDetails(tester, cubit);

      expect(find.text('115.00'), findsOneWidget);
      expect(find.text('35.00'), findsNothing);
      expect(
        find.text('175.00'),
        findsNothing,
        reason: 'nothing to strike through when nothing is discounted',
      );
    },
  );

  testWidgets(
    'an add-on picked on this screen moves the figure labelled Total',
    (tester) async {
      // The offer prices the WASH. The add-on grid is on the SAME screen, so a
      // Total that a purchase made here does not move is a mislabelled number:
      // the summary would charge 90.00 against a displayed 35.00.
      final repo = RecordingBookingRepo(addOnGrossMinor: 5500);
      final cubit = buildCubit(
        repo,
        withService: serviceWithAddOn,
        offerListPriceMinor: 17500,
        offerTargetPriceMinor: 3500,
      );
      addTearDown(cubit.close);

      await pumpDetails(tester, cubit);
      expect(find.text('35.00'), findsOneWidget);

      // The grid titles off `context.isAr`, which reads the LanguageCubit and
      // not the widget locale, so the label under test is the Arabic one.
      await tester.tap(find.text('تلميع الإطارات'));
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);

      expect(
        find.text('90.00'),
        findsOneWidget,
        reason: 'offer price 35.00 + the 55.00 add-on the customer just picked',
      );
      expect(find.text('35.00'), findsNothing);
      expect(
        find.text('230.00'),
        findsOneWidget,
        reason: 'the struck figure is what the same basket costs without the '
            'offer, so the gap between the two stays the offer own saving',
      );
      expect(find.text('175.00'), findsNothing);
    },
  );

  testWidgets(
    'an inverted offer is priced off the QUOTE — a stale target is never the '
    'Total',
    (tester) async {
      // An admin published a 99.00 target on a 175.00 wash, then dropped the
      // wash to 79.00. The server clamps the discount to 0 and charges the
      // lower list price, so the target is a figure nobody will be charged.
      //
      // Suppressing only the strikethrough left 99.00 standing alone under the
      // label "Total" — HIGHER than the summary's own total, which is the one
      // direction a displayed price must never be wrong in. The D-4 override
      // exists to stop a step-change between this screen and the summary; an
      // inverted pair is exactly the case it cannot honour, so the whole
      // override switches off and the screen prices off the quote like any
      // booking that never came through an offer.
      final repo = RecordingBookingRepo();
      final cubit = buildCubit(
        repo,
        offerListPriceMinor: 7900,
        offerTargetPriceMinor: 9900,
      );
      addTearDown(cubit.close);

      await pumpDetails(tester, cubit);

      expect(
        find.text('79.00'),
        findsNothing,
        reason: 'nothing to strike through when nothing is discounted',
      );
      expect(
        find.text('99.00'),
        findsNothing,
        reason: 'the stale target is above what the summary charges — showing '
            'it as the Total quotes a price the customer never pays',
      );
      expect(
        find.text('115.00'),
        findsOneWidget,
        reason: 'the plain quote total, exactly as an offer-less booking',
      );
    },
  );

  testWidgets(
    'the offer price survives a return from the payment page',
    (tester) async {
      // It is state, not a one-shot handoff: walking forward to the summary
      // and back must not drop the figure the card promised.
      final repo = RecordingBookingRepo();
      final cubit = buildCubit(
        repo,
        offerListPriceMinor: 17500,
        offerTargetPriceMinor: 3500,
      );
      addTearDown(cubit.close);

      await pumpDetails(tester, cubit);
      await pumpSummary(tester, cubit);
      await pumpDetails(tester, cubit);

      expect(find.text('35.00'), findsOneWidget);
      expect(find.text('175.00'), findsOneWidget);
    },
  );

  testWidgets(
    'an offer the server REFUSED stops pricing this screen',
    (tester) async {
      // The figures survive navigation ON PURPOSE (the test above), because
      // the details re-quote is deliberately bare and clearing them alongside
      // the applied code would blank the very numbers D-4 keeps on screen.
      //
      // A REFUSAL is the other thing entirely. The summary asked for the offer
      // and the server said no — cap consumed, campaign over, the customer
      // ineligible (UCC23 A3) — so the order is priced without it and 115.00 is
      // charged. Keeping the pair here left the customer bounced back to
      // "175.00 struck through, then 35.00", tapping Book now, and landing on
      // 115.00: the exact step-change the whole override exists to remove,
      // pointing the wrong way.
      final repo = RecordingBookingRepo(
        quoteFailure: (_, offerId) => offerId == null
            ? null
            : const ServerFailure(
                'This code is no longer valid',
                type: FailureType.validation,
              ),
      );
      PendingPromoCode.instance.hold(offerId: 'offer-1');
      addTearDown(PendingPromoCode.instance.takeHandoff);

      final cubit = buildCubit(
        repo,
        offerListPriceMinor: 17500,
        offerTargetPriceMinor: 3500,
      );
      addTearDown(cubit.close);

      // The summary is where the offer is asked for, and refused.
      await pumpSummary(tester, cubit);
      expect(cubit.state.appliedOfferId, isNull);
      expect(cubit.state.appliedPromoCode, isNull);

      await pumpDetails(tester, cubit);

      expect(
        find.text('35.00'),
        findsNothing,
        reason: 'a refused offer prices nothing — the card promised a deal the '
            'server has since taken away',
      );
      expect(find.text('175.00'), findsNothing);
      expect(
        find.text('115.00'),
        findsOneWidget,
        reason: 'the same figure the summary charges, so Book now no longer '
            'walks into a higher number',
      );
    },
  );
}
