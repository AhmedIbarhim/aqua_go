import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/helpers/shimmer_helper.dart';
import 'package:aqua_go/features/booking/data/models/quote_model.dart';
import 'package:aqua_go/features/booking/domain/configs/booking_flow_config.dart';
import 'package:aqua_go/features/offers/domain/pending_promo_code.dart';
import 'package:aqua_go/features/booking/presentation/widgets/booking_summary_widgets/booking_payable_total.dart';
import 'package:aqua_go/features/booking/presentation/widgets/booking_summary_widgets/price_unavailable_card.dart';
import 'package:aqua_go/features/booking/presentation/widgets/booking_summary_widgets/payment_summary_card.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/promo_summary_harness.dart';

/// A price call that FAILED is not a price call still in flight, and the
/// summary has to say so.
///
/// Both priced flows wait on a backend figure before they state any number
/// (`isPriceLocked`, booking_payable_total.dart), and while they wait the
/// payment summary holds its place with a shimmer. That is right for a request
/// that is still outstanding. It was also what the screen was left holding when
/// the request came back a failure — forever, because nothing re-fires it: the
/// service flow's `/quote` and the package flow's wash-charge preview are both
/// fired once, from `initState`'s post-frame callback. The failure was reported
/// in a snackbar, which is transient, so a customer who looked away was left on
/// a screen that shimmers indefinitely with a dead Confirm button and no
/// explanation, and no way forward but to leave the flow and come back.
///
/// So the wait is THREE states, not two, and these tests pin them apart on the
/// real screen for BOTH priced flows:
///   * in flight     → the shimmer (the price is coming);
///   * FAILED        → an inline, persistent message and a Retry (it is not);
///   * priced        → the real card.
///
/// Conflating the first two is the bug. Retry has to re-fire the call THIS FLOW
/// prices from — they are different endpoints — so it goes through the same
/// dispatch `initState` uses rather than a second copy of that decision.
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

  group('service flow — the quote is the price', () {
    testWidgets('in flight shows the shimmer, not the failure', (tester) async {
      final repo = _FlakyQuoteRepo(failuresBeforeSuccess: 1);
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummaryPendingQuote(tester, cubit);

      expect(
        cubit.state.quote,
        isNull,
        reason: 'the quote must still be outstanding for this to test anything',
      );
      expect(find.byType(PaymentSummaryShimmer), findsOneWidget);
      expect(
        find.byType(PriceUnavailableCard),
        findsNothing,
        reason: 'a request that has not answered yet has not failed',
      );
      expect(find.byType(PaymentSummaryCard), findsNothing);

      await settleFailure(tester);
    });

    testWidgets('a failed quote replaces the shimmer with an inline retry', (
      tester,
    ) async {
      final repo = _FlakyQuoteRepo(failuresBeforeSuccess: 1);
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummaryPendingQuote(tester, cubit);
      await settleFailure(tester);

      expect(cubit.state.quote, isNull);
      expect(
        find.byType(PaymentSummaryShimmer),
        findsNothing,
        reason:
            'nothing is loading — the shimmer promises a price that is not '
            'coming, and it is the only thing on screen once the snackbar goes',
      );
      expect(
        find.byType(PriceUnavailableCard),
        findsOneWidget,
        reason: 'the failure has to survive the snackbar that announced it',
      );
      expect(
        find.byType(PaymentSummaryCard),
        findsNothing,
        reason: 'a price that never arrived is still not a price of zero',
      );
    });

    testWidgets('retry re-fires /quote — the call THIS flow prices from', (
      tester,
    ) async {
      final repo = _FlakyQuoteRepo(failuresBeforeSuccess: 1);
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummaryPendingQuote(tester, cubit);
      await settleFailure(tester);
      expect(repo.quoteCalls.length, 1);

      await tapRetry(tester);

      expect(
        repo.quoteCalls.length,
        2,
        reason: 'retry has to re-fire the quote, not merely clear the error',
      );
      expect(
        repo.previewCalls,
        0,
        reason:
            'the service flow has no wash-charge preview to fetch — a '
            'hard-coded retry would call the other flow\'s endpoint',
      );
      expect(cubit.state.quote, isNotNull);
      expect(
        find.byType(PaymentSummaryCard),
        findsOneWidget,
        reason: 'the retry succeeded, so the real card takes over',
      );
      expect(find.byType(PriceUnavailableCard), findsNothing);
      expect(find.byType(PaymentSummaryShimmer), findsNothing);
    });

    testWidgets('a retry that re-attempts a held offer reads as in flight', (
      tester,
    ) async {
      // The narrow window this covers is the same conflation, running the other
      // way. An offer whose apply went UNANSWERED is put back in the handoff
      // slot, so a retry re-takes it and goes through `applyOffer` rather than
      // `reprice` — a third way into the price call. If that path does not
      // clear the failed flag on its way out, the screen keeps offering a Retry
      // for a request that is already in flight, and a second tap fires a
      // duplicate quote.
      PendingPromoCode.instance.hold(offerId: 'offer-1');
      addTearDown(PendingPromoCode.instance.takeHandoff);

      final repo = _FlakyQuoteRepo(failuresBeforeSuccess: 3);
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummaryPendingQuote(tester, cubit);
      await settleFailure(tester);

      expect(
        repo.quoteCalls.length,
        3,
        reason:
            'entry is applyOffer (retried once, because an unanswered '
            'request is no verdict on the offer) plus the bare reprice that '
            'follows it',
      );
      expect(
        find.byType(PriceUnavailableCard),
        findsOneWidget,
        reason: 'all three attempts failed, so there is no price at all',
      );

      final retry = find.byKey(const ValueKey('price-retry'));
      await tester.ensureVisible(retry);
      await tester.pump();
      await tester.tap(retry);
      // One frame to start the call, then a tick shorter than the round trip:
      // the request is genuinely outstanding at this point.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      expect(
        repo.quoteCalls.length,
        4,
        reason:
            'the retry re-attempts the offer the customer accepted, not a '
            'bare quote that would silently drop their deal',
      );
      expect(
        repo.offerCalls.last,
        'offer-1',
        reason: 'the held offer goes back on the wire',
      );
      expect(
        cubit.state.priceLoadFailed,
        isFalse,
        reason:
            'a call is in flight — the screen must not still be offering a '
            'Retry for it',
      );
      expect(find.byType(PriceUnavailableCard), findsNothing);
      expect(find.byType(PaymentSummaryShimmer), findsOneWidget);

      await settle(tester);
    });
  });

  group('package flow — the wash-charge preview is the price', () {
    testWidgets('in flight shows the shimmer, not the failure', (tester) async {
      final repo = _FlakyPreviewRepo(failuresBeforeSuccess: 1);
      final cubit = buildPackageCubit(repo);
      addTearDown(cubit.close);

      await pumpSummaryPendingQuote(tester, cubit);

      expect(cubit.state.flowConfig.isPackage, isTrue);
      expect(cubit.state.quote, isNull);
      expect(find.byType(PaymentSummaryShimmer), findsOneWidget);
      expect(find.byType(PriceUnavailableCard), findsNothing);

      await settleFailure(tester);
    });

    testWidgets('a failed preview replaces the shimmer with an inline retry', (
      tester,
    ) async {
      final repo = _FlakyPreviewRepo(failuresBeforeSuccess: 1);
      final cubit = buildPackageCubit(repo);
      addTearDown(cubit.close);

      await pumpSummaryPendingQuote(tester, cubit);
      await settleFailure(tester);

      expect(cubit.state.quote, isNull);
      expect(
        find.byType(PaymentSummaryShimmer),
        findsNothing,
        reason:
            'the package flow reaches the same dead end down its own road, '
            'and the narrowing that stopped it submitting a fabricated SAR '
            '0.00 is what made an exit from it necessary',
      );
      expect(find.byType(PriceUnavailableCard), findsOneWidget);
      expect(find.byType(PaymentSummaryCard), findsNothing);
    });

    testWidgets('retry re-fires the preview — not the service flow\'s quote', (
      tester,
    ) async {
      final repo = _FlakyPreviewRepo(failuresBeforeSuccess: 1);
      final cubit = buildPackageCubit(repo);
      addTearDown(cubit.close);

      await pumpSummaryPendingQuote(tester, cubit);
      await settleFailure(tester);
      expect(repo.previewCalls, 1);

      await tapRetry(tester);

      expect(
        repo.previewCalls,
        2,
        reason:
            'the package flow prices from the preview, so that is what '
            'retry must ask for again',
      );
      expect(
        repo.quoteCalls,
        isEmpty,
        reason:
            'the package flow has no quote endpoint at all — calling it '
            'here is the drift this asserts against',
      );
      expect(cubit.state.quote, isNotNull);
      expect(find.byType(PaymentSummaryCard), findsOneWidget);
      expect(find.byType(PriceUnavailableCard), findsNothing);
      expect(find.byType(PaymentSummaryShimmer), findsNothing);
    });
  });

  group('the three states, as the shipped resolver decides them', () {
    // Asserted on the SHIPPED helper rather than a copy of it: a local
    // re-declaration would keep passing after the real one changed.
    const service = BookingFlowConfig(flowType: BookingFlowType.service);
    const package = BookingFlowConfig(flowType: BookingFlowType.package);

    test('pending and unavailable are DIFFERENT states, per priced flow', () {
      for (final config in [service, package]) {
        expect(
          resolvePriceDisplay(
            config: config,
            quote: null,
            priceLoadFailed: false,
          ),
          PriceDisplay.pending,
          reason: '${config.flowType}: no price yet, and one is still coming',
        );
        expect(
          resolvePriceDisplay(
            config: config,
            quote: null,
            priceLoadFailed: true,
          ),
          PriceDisplay.unavailable,
          reason:
              '${config.flowType}: no price, and none is coming — the '
              'state that used to render as an endless shimmer',
        );
      }
    });

    test('a price that landed is ready, whatever an earlier failure said', () {
      // A reprice that fails over an existing quote leaves that quote on the
      // state, and it is still a real server figure. The dead end this fixes is
      // having NO price at all, so the card stays.
      final quote = quotePayload(promoCode: null, quoteId: 'q1');
      for (final failed in [true, false]) {
        expect(
          resolvePriceDisplay(
            config: service,
            quote: quote,
            priceLoadFailed: failed,
          ),
          PriceDisplay.ready,
        );
      }
    });

    test('flows that never ask the server for a price are always ready', () {
      // Reschedule and gift redemption render no payment summary at all, so
      // there is nothing to withhold and nothing to retry. Reporting either as
      // unavailable would put a Retry button on a screen with no price call
      // behind it.
      for (final flowType in BookingFlowType.values) {
        final config = BookingFlowConfig(flowType: flowType);
        if (config.awaitsBackendPrice) continue;
        expect(
          resolvePriceDisplay(
            config: config,
            quote: null,
            priceLoadFailed: true,
          ),
          PriceDisplay.ready,
          reason: '$flowType prices nothing from the server',
        );
      }
    });

    test('the shipped gate agrees with the resolver, so they cannot drift', () {
      // The Confirm button is gated on `isPriceLocked`, and it must stay
      // disabled in BOTH non-ready states — a retry affordance is a way out of
      // the dead end, not a way to submit an unpriced order.
      for (final config in [service, package]) {
        for (final failed in [true, false]) {
          final display = resolvePriceDisplay(
            config: config,
            quote: null,
            priceLoadFailed: failed,
          );
          expect(display == PriceDisplay.ready, isFalse);
          expect(isPriceLocked(config: config, quote: null), isFalse);
        }
      }
    });
  });
}

/// Advances frames far enough for the failed round trip to land and its
/// snackbar to come and go, WITHOUT `pumpAndSettle`.
///
/// The failure state is static, so it would settle — but the snackbar that
/// announces the failure runs its own timer, and the loading overlay is
/// inserted from a post-frame callback. Explicit frames keep both honest.
Future<void> settleFailure(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 10));
  }
  await tester.pump(const Duration(seconds: 5));
}

/// Taps the inline Retry the failure state offers, and lets the re-fired price
/// call land.
Future<void> tapRetry(WidgetTester tester) async {
  final retry = find.byKey(const ValueKey('price-retry'));
  await tester.ensureVisible(retry);
  await tester.pump();
  await tester.tap(retry);
  await settle(tester);
}

/// A quote that fails its first [failuresBeforeSuccess] calls and then answers
/// normally — a timeout, a 5xx, a dropped connection, and then the network
/// coming back, which is the whole point of offering a retry.
class _FlakyQuoteRepo extends RecordingBookingRepo {
  _FlakyQuoteRepo({required this.failuresBeforeSuccess});

  final int failuresBeforeSuccess;

  /// Counts the OTHER flow's price call, so a retry that fires the wrong
  /// endpoint is caught rather than merely failing to fire the right one.
  int previewCalls = 0;

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
    quoteCalls.add(promoCode);
    offerCalls.add(offerId);
    await networkTick();
    if (quoteCalls.length <= failuresBeforeSuccess) {
      return left(ServerFailure('quote unavailable'));
    }
    return right(
      quotePayload(promoCode: promoCode, quoteId: 'quote-${quoteCalls.length}'),
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  previewScheduleSubscriptionWash({
    required String subscriptionId,
    required String washId,
    required Map<String, dynamic> scheduleData,
  }) async {
    previewCalls++;
    await networkTick();
    return left(ServerFailure('the service flow must never ask for this'));
  }
}

/// The wash-charge preview failing its first [failuresBeforeSuccess] calls and
/// then answering with the PAYABLE wash UC-C13 §4 describes (an 8.00 SAR
/// optional add-on).
class _FlakyPreviewRepo extends RecordingBookingRepo {
  _FlakyPreviewRepo({required this.failuresBeforeSuccess});

  final int failuresBeforeSuccess;

  int previewCalls = 0;

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  previewScheduleSubscriptionWash({
    required String subscriptionId,
    required String washId,
    required Map<String, dynamic> scheduleData,
  }) async {
    previewCalls++;
    await networkTick();
    if (previewCalls <= failuresBeforeSuccess) {
      return left(ServerFailure('wash-charge preview unavailable'));
    }
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
