import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/helpers/shimmer_helper.dart';
import 'package:aqua_go/features/booking/domain/configs/booking_flow_config.dart';
import 'package:aqua_go/features/booking/presentation/controllers/booking_state.dart';
import 'package:aqua_go/features/booking/presentation/widgets/booking_summary_widgets/booking_payable_total.dart';
import 'package:aqua_go/features/booking/presentation/widgets/payment_summary_card.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/promo_summary_harness.dart';

/// The SUBSCRIPTION-WASH (package) summary has the same three-state price the
/// service summary has, and reaches it down a different road.
///
/// It takes no quote. It prices from the read-only wash-charge preview, which
/// the cubit maps into a synthetic `QuoteModel` and puts on the SAME
/// `state.quote` field — and which the summary fires from a post-frame
/// callback, so the first frames of a package wash have no price at all. Every
/// figure on the card is `quote?.<field> ?? 0`, so those frames state a
/// subtotal, a VAT and a total of SAR 0.00 for a wash that costs money.
///
/// The price-lock gate that fixed this for the service flow did not cover it:
/// `isPriceLocked` short-circuits on `!config.requiresQuote`, and
/// `requiresQuote` is `flowType == service` while `showPaymentSummary` is
/// `service || package`. So the gate was open exactly where the card renders
/// but no quote is coming. These tests pin the three states apart on the real
/// screen, for BOTH flows, so the two cannot drift again.
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

  group('package summary while the wash-charge preview is unresolved', () {
    testWidgets('the summary card never states a fabricated SAR 0.00', (
      tester,
    ) async {
      final repo = _PreviewBookingRepo();
      final cubit = buildPackageCubit(repo);
      addTearDown(cubit.close);

      await pumpSummaryPendingQuote(tester, cubit);

      expect(
        cubit.state.flowConfig.isPackage,
        isTrue,
        reason: 'this test is about the package flow specifically',
      );
      expect(
        cubit.state.quote,
        isNull,
        reason: 'the wash-charge preview must still be in flight for this to '
            'test anything',
      );
      expect(
        find.byType(PaymentSummaryCard),
        findsNothing,
        reason: 'with no preview every figure on the card is `?? 0`, so it '
            'prices a payable wash at nothing',
      );
      expect(
        find.byType(PaymentSummaryShimmer),
        findsOneWidget,
        reason: 'the section keeps its place with a placeholder — the absence '
            'of a price, not a price of nothing',
      );

      await settle(tester);
    });
  });

  group('package summary once the preview resolves', () {
    testWidgets('the real card takes over, priced from the preview', (
      tester,
    ) async {
      final repo = _PreviewBookingRepo();
      final cubit = buildPackageCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);

      expect(
        repo.previewCalls,
        1,
        reason: 'the summary asks for the preview exactly once on entry',
      );
      expect(cubit.state.quote, isNotNull);
      expect(find.byType(PaymentSummaryCard), findsOneWidget);
      expect(find.byType(PaymentSummaryShimmer), findsNothing);
    });
  });

  group('package summary when the preview never resolves', () {
    testWidgets('the gate holds and the failure is reported, not swallowed', (
      tester,
    ) async {
      final cubit = buildPackageCubit(_FailingPreviewBookingRepo());
      addTearDown(cubit.close);

      // Pumped by hand rather than through `pumpSummary`: the placeholder is
      // a shimmer, and a shimmer never settles. On every other path it is
      // replaced the moment the price lands, which is why `pumpAndSettle`
      // works there; here it is what the screen is left holding, so the frames
      // are advanced explicitly far enough for the failed round trip to land.
      await pumpSummaryPendingQuote(tester, cubit);
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }

      expect(
        find.byType(PaymentSummaryCard),
        findsNothing,
        reason: 'a preview that never arrived is not a price of zero',
      );
      expect(find.byType(PaymentSummaryShimmer), findsOneWidget);
      expect(
        cubit.state.status,
        BookingStatus.failure,
        reason: 'the screen now WAITS on this call, so a silent `initial` '
            'would leave a placeholder and a dead Confirm button with nothing '
            'saying why — the service flow reports the same failure',
      );
      expect(cubit.state.errorMessage, isNotNull);
    });
  });

  group('the invariant the gate rests on', () {
    test('every flow that shows the payment summary waits for its price', () {
      // The card reads `quote?.<field> ?? 0`, so ANY flow that renders it and
      // does not wait renders a fabricated zero. This is the implication that
      // broke: `showPaymentSummary` grew to include the package flow and the
      // readiness predicate did not follow. Break it again and this fails
      // rather than the zeros coming back.
      for (final flowType in BookingFlowType.values) {
        final config = BookingFlowConfig(flowType: flowType);
        if (config.showPaymentSummary) {
          expect(
            config.awaitsBackendPrice,
            isTrue,
            reason:
                '$flowType renders the payment summary but is not treated as '
                'waiting for a backend price — booking_summary_view.dart would '
                'state SAR 0.00 for it before the price lands',
          );
        }
      }
    });

    test('the gate is the shipped helper, asserted per flow', () {
      // Asserted on the SHIPPED predicate rather than a copy of it — a local
      // re-declaration here would keep passing after the real one changed.
      const service = BookingFlowConfig(flowType: BookingFlowType.service);
      const package = BookingFlowConfig(flowType: BookingFlowType.package);
      const reschedule = BookingFlowConfig(
        flowType: BookingFlowType.reschedule,
      );
      const giftRedeem = BookingFlowConfig(
        flowType: BookingFlowType.giftRedeem,
      );

      // Both priced flows wait, and both are released by the same arrival:
      // the package flow's preview lands on `state.quote` too.
      expect(isPriceLocked(config: service, quote: null), isFalse);
      expect(isPriceLocked(config: package, quote: null), isFalse);

      // Neither of the two unpriced flows renders a payment summary at all, so
      // waiting would gate their Confirm button on a price that is never
      // coming. They are unchanged.
      expect(reschedule.showPaymentSummary, isFalse);
      expect(giftRedeem.showPaymentSummary, isFalse);
      expect(isPriceLocked(config: reschedule, quote: null), isTrue);
      expect(isPriceLocked(config: giftRedeem, quote: null), isTrue);
    });

    test('requiresQuote still means the service flow only', () {
      // The fix must NOT widen `requiresQuote`: that predicate also drives the
      // initial quote fetch (booking_details_view + booking_summary_view's
      // initState), and a package flow that "requires a quote" would fire a
      // /quote call it has no quote endpoint for and skip the preview entirely.
      for (final flowType in BookingFlowType.values) {
        expect(
          BookingFlowConfig(flowType: flowType).requiresQuote,
          flowType == BookingFlowType.service,
          reason: '$flowType must not have been swept into requiresQuote',
        );
      }
    });
  });
}

/// A booking repository that answers the subscription-wash charge preview with
/// a PAYABLE wash — the 8.00 SAR optional add-on case UC-C13 §4 describes —
/// after a real round trip, so the in-flight window actually exists.
class _PreviewBookingRepo extends RecordingBookingRepo {
  int previewCalls = 0;

  @override
  Future<Either<Failure, Map<String, dynamic>>> previewScheduleSubscriptionWash({
    required String subscriptionId,
    required String washId,
    required Map<String, dynamic> scheduleData,
  }) async {
    previewCalls++;
    await networkTick();
    return right(const {
      'chargeTotalMinor': 800,
      'breakdown': {
        'grossMinor': 800,
        'netMinor': 696,
        'vatMinor': 104,
        'currency': 'SAR',
        'totalMinor': 800,
      },
      'addonLines': [
        {'addonId': 'addon-1', 'chargedMinor': 800},
      ],
    });
  }
}

/// The preview call failing — no network, a timeout, a 5xx. The wash still
/// costs whatever it costs; this client simply does not know it.
class _FailingPreviewBookingRepo extends RecordingBookingRepo {
  @override
  Future<Either<Failure, Map<String, dynamic>>> previewScheduleSubscriptionWash({
    required String subscriptionId,
    required String washId,
    required Map<String, dynamic> scheduleData,
  }) async {
    await networkTick();
    return left(ServerFailure('wash-charge preview unavailable'));
  }
}
