import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
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
}
