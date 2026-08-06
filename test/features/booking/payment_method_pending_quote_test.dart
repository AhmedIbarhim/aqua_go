import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/helpers/shimmer_helper.dart';
import 'package:aqua_go/core/utils/saudi_wire_format.dart';
import 'package:aqua_go/features/booking/data/models/quote_model.dart';
import 'package:aqua_go/features/booking/domain/configs/booking_flow_config.dart';
import 'package:aqua_go/features/booking/presentation/widgets/booking_summary_widgets/booking_payable_total.dart';
import 'package:aqua_go/features/booking/presentation/widgets/booking_summary_widgets/payment_method_selection.dart';
import 'package:aqua_go/features/booking/presentation/widgets/payment_summary_card.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/promo_summary_harness.dart';

/// The booking summary's payment section reads a THREE-state quote through a
/// two-state if/else.
///
/// The states are: (a) the quote has not come back yet, (b) it came back and
/// something is payable, (c) it came back and nothing is. `payableTotalMajor`
/// answers 0.0 for a null breakdown BY DESIGN, so (a) is indistinguishable from
/// (c) to `needsPaymentMethod` alone — and the else-branch told the customer
/// "No payment required — this booking is fully covered" on the FIRST FRAME of
/// an ordinary paid booking, swapping to a card picker a moment later when the
/// quote landed.
///
/// These tests pin all three states apart on the real screen.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTranslations();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheClient.init();
  });

  /// The message is asserted by localization KEY, not by wording: under this
  /// harness `tr(context: context)` resolves to the key, and the assertion is
  /// about WHICH message the screen decided to show.
  const noPaymentCopy = LocaleKeys.bookings_no_payment_required;

  group('payment section while the quote is unresolved', () {
    testWidgets(
      'a payable booking never claims "no payment required" before its quote lands',
      (tester) async {
        final repo = RecordingBookingRepo();
        final cubit = buildCubit(repo);
        addTearDown(cubit.close);

        await pumpSummaryPendingQuote(tester, cubit);

        expect(
          cubit.state.quote,
          isNull,
          reason: 'the initial quote must still be in flight for this to test '
              'anything',
        );
        expect(
          find.text(noPaymentCopy),
          findsNothing,
          reason: 'an unresolved quote is not a free booking — this copy is a '
              'claim the screen cannot make yet',
        );

        await settle(tester);
      },
    );

    testWidgets('neither the picker nor the copy renders in that window', (
      tester,
    ) async {
      final repo = RecordingBookingRepo();
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummaryPendingQuote(tester, cubit);

      expect(find.text(noPaymentCopy), findsNothing);
      expect(find.byType(PaymentMethodSelection), findsNothing);

      await settle(tester);
    });
  });

  group('payment section once the quote resolves', () {
    testWidgets('a normal paid booking gets the payment picker', (
      tester,
    ) async {
      final repo = RecordingBookingRepo();
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);

      expect(cubit.state.quote, isNotNull);
      expect(
        find.byType(PaymentMethodSelection),
        findsOneWidget,
        reason: 'the picker must still render for every booking that has '
            'something to pay',
      );
      expect(find.text(noPaymentCopy), findsNothing);
    });

    testWidgets('a genuinely zero-total quote gets the "no payment" copy', (
      tester,
    ) async {
      final cubit = buildCubit(_ZeroTotalBookingRepo());
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);

      expect(cubit.state.quote, isNotNull);
      expect(
        find.text(noPaymentCopy),
        findsOneWidget,
        reason: 'a fully covered booking is exactly what this copy is for',
      );
      expect(find.byType(PaymentMethodSelection), findsNothing);
    });
  });

  group('price breakdown while the quote is unresolved', () {
    testWidgets('the summary card never states a fabricated SAR 0.00', (
      tester,
    ) async {
      final repo = RecordingBookingRepo();
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummaryPendingQuote(tester, cubit);

      expect(
        cubit.state.quote,
        isNull,
        reason: 'the initial quote must still be in flight for this to test '
            'anything',
      );
      expect(
        find.byType(PaymentSummaryCard),
        findsNothing,
        reason: 'every figure on the card is `quote?.<field> ?? 0`, so with no '
            'quote it prices a payable order at zero',
      );
      expect(
        find.byType(PaymentSummaryShimmer),
        findsOneWidget,
        reason: 'the section keeps its place with a placeholder — the absence '
            'of a price, not a price of nothing',
      );

      await settle(tester);
    });

    testWidgets('the real card takes over once the quote lands', (
      tester,
    ) async {
      final repo = RecordingBookingRepo();
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);

      expect(cubit.state.quote, isNotNull);
      expect(find.byType(PaymentSummaryCard), findsOneWidget);
      expect(find.byType(PaymentSummaryShimmer), findsNothing);
    });

    testWidgets('a genuinely zero-total quote still gets the real card', (
      tester,
    ) async {
      final cubit = buildCubit(_ZeroTotalBookingRepo());
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);

      expect(
        find.byType(PaymentSummaryCard),
        findsOneWidget,
        reason: 'a resolved free order HAS a price — zero — and is entitled to '
            'see it stated; only the unresolved case is withheld',
      );
      expect(find.byType(PaymentSummaryShimmer), findsNothing);
    });
  });

  group('the invariant the gate rests on', () {
    test('every flow that shows the payment picker also waits for a price', () {
      // The gate waits only where `awaitsBackendPrice` says a price is coming.
      // If a flow ever shows the picker WITHOUT one coming, waiting would hide
      // the picker forever — worse than the flash being fixed. Today no such
      // flow exists, and this pins it: break the implication and this fails
      // rather than the picker silently vanishing in production.
      for (final flowType in BookingFlowType.values) {
        final config = BookingFlowConfig(flowType: flowType);
        if (config.showPaymentMethod) {
          expect(
            config.awaitsBackendPrice,
            isTrue,
            reason:
                '$flowType shows the payment picker but never resolves a price '
                '— booking_summary_view.dart gates the picker on the price '
                'being resolved, so this flow would lose it entirely',
          );
        }
      }
    });

    test('a flow that shows the picker without a price counts as resolved', () {
      // The gate's own shape, asserted on the SHIPPED predicate rather than a
      // copy of it — `isPriceLocked` is the single helper the payment section,
      // the breakdown card and the confirm button all call, and a local
      // re-declaration here would keep passing after the real one changed.
      // `!awaitsBackendPrice` short-circuits it, so such a flow (were one
      // added) renders its payment section on the first frame exactly as it
      // does today.
      //
      // The short-circuit is keyed on `awaitsBackendPrice`, NOT `requiresQuote`
      // — gift redemption answers false to both, but the package flow answers
      // false to `requiresQuote` while still waiting on a price (its
      // wash-charge preview), and gating it on the routing predicate is what
      // let it state SAR 0.00. See package_summary_pending_price_test.dart.
      final quoting = BookingFlowConfig(flowType: BookingFlowType.service);
      final unpriced = BookingFlowConfig(flowType: BookingFlowType.giftRedeem);
      expect(unpriced.requiresQuote, isFalse);
      expect(unpriced.awaitsBackendPrice, isFalse);

      expect(isPriceLocked(config: unpriced, quote: null), isTrue);
      expect(isPriceLocked(config: quoting, quote: null), isFalse);
    });
  });
}

/// Answers every quote with a booking that is FULLY covered: a real gross, a
/// zero total and a zero amount due — the shape a 100% promo or a full points
/// redemption produces.
class _ZeroTotalBookingRepo extends RecordingBookingRepo {
  @override
  Future<Either<Failure, QuoteModel>> getQuote({
    required String packageId,
    required double lat,
    required double lng,
    List<Map<String, dynamic>>? addOns,
    String? promoCode,
    String? offerId,
    int? pointsToApply,
    List<String> addOnIds = const [],
    int? carCount,
  }) async {
    await networkTick();
    return right(
      QuoteModel.fromJson({
        'quoteId': 'quote-free',
        'currency': 'SAR',
        'expiresAt': toWireDateTime(
          saudiNow().add(const Duration(minutes: 15)),
        ),
        'breakdown': {
          'grossMinor': grossWithoutPromoMinor,
          'netMinor': 0,
          'vatMinor': 0,
          'currency': 'SAR',
          'totalMinor': 0,
          'promoDiscountMinor': grossWithoutPromoMinor,
          'amountDueMinor': 0,
        },
        'lines': const [],
      }),
    );
  }
}
