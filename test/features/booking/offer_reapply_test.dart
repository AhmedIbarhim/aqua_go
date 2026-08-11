import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/booking/presentation/widgets/booking_summary_widgets/promo_code_section.dart';
import 'package:aqua_go/features/offers/domain/pending_promo_code.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/promo_summary_harness.dart';

/// A superseded offer is REMEMBERED and RESTORABLE, never destroyed.
///
/// The bug this pins: applying a TYPED code over a live offer dropped
/// `appliedOfferId` permanently for the session, so removing the typed code
/// could not bring the offer back — while the offer's two display figures
/// survived, leaving the details screen promising 35.00 for an offer that was
/// gone and the summary charging 157.50.
///
/// [BookingState.rememberedOfferId] is what survives. It outlives BOTH ways an
/// offer stops pricing the order (the customer removes it; a typed code
/// supersedes it), and is dropped only when the server SETTLES the offer's fate
/// against it — the same `_isPromoVerdict` discipline that guards
/// `clearOfferPrices`. A transport failure decides nothing and drops nothing.
///
/// The re-apply card is the affordance. Nothing re-prices on its own: a silent
/// re-price the customer did not ask for is worse than a visible offer to
/// restore one.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await CacheClient.init();
    await EasyLocalization.ensureInitialized();
    await loadTranslations();
  });

  /// The re-apply affordance, keyed so the test never depends on its copy.
  final reapplyCard = find.byKey(const ValueKey('offer-reapply'));

  /// The applied-code card's remove action. Found by its RAW KEY: the harness's
  /// localization resolves to key strings, exactly as the sibling promo tests
  /// assume (`promo_code_lifecycle_test`).
  final removeCode = find.text('bookings.delete_promo_code');

  /// Arms the single-shot handoff the offers surface leaves behind, so the
  /// summary applies the offer on its first frame exactly as the real flow does.
  void holdOffer(String offerId) {
    PendingPromoCode.instance.hold(offerId: offerId);
    addTearDown(PendingPromoCode.instance.takeHandoff);
  }

  group('the four transitions', () {
    testWidgets('offer active — the card is hidden', (tester) async {
      final repo = RecordingBookingRepo();
      holdOffer('offer-1');
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);

      expect(cubit.state.appliedOfferId, 'offer-1');
      expect(
        reapplyCard,
        findsNothing,
        reason: 'nothing to restore while the offer is what prices the order',
      );
    });

    testWidgets('offer removed — the card is shown', (tester) async {
      final repo = RecordingBookingRepo();
      holdOffer('offer-1');
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      await tester.tap(removeCode);
      await settle(tester);

      expect(cubit.state.appliedOfferId, isNull);
      expect(cubit.state.appliedPromoCode, isNull);
      expect(
        cubit.state.rememberedOfferId,
        'offer-1',
        reason: 'removing the code says nothing about the offer being over',
      );
      expect(reapplyCard, findsOneWidget);
    });

    testWidgets('a typed code applied over it — the card is hidden', (
      tester,
    ) async {
      final repo = RecordingBookingRepo();
      holdOffer('offer-1');
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      // The promo box shows the applied chip while the offer stands, so the
      // real route to a typed code is through the remove action — which is
      // also the route that used to destroy the offer for good.
      await tester.tap(removeCode);
      await settle(tester);
      await applyPromo(tester, 'OTHERCODE');

      expect(cubit.state.appliedPromoCode, 'OTHERCODE');
      expect(
        cubit.state.appliedOfferId,
        isNull,
        reason: 'this sale did not come through the offer — attribution is off',
      );
      expect(
        cubit.state.rememberedOfferId,
        'offer-1',
        reason: 'attribution being off is not the offer being gone',
      );
      expect(
        reapplyCard,
        findsNothing,
        reason: 'a code the customer just typed is what prices the order',
      );
    });

    testWidgets('the typed code removed — the card is shown again', (
      tester,
    ) async {
      final repo = RecordingBookingRepo();
      holdOffer('offer-1');
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      await tester.tap(removeCode);
      await settle(tester);
      await applyPromo(tester, 'OTHERCODE');
      expect(reapplyCard, findsNothing);

      await tester.tap(removeCode);
      await settle(tester);

      expect(cubit.state.appliedPromoCode, isNull);
      expect(
        reapplyCard,
        findsOneWidget,
        reason:
            'the whole point — the offer the typed code displaced is back '
            'within reach instead of destroyed for the session',
      );
    });
  });

  group('on the cubit', () {
    test(
      'a typed code applied straight over a live offer remembers it',
      () async {
        // The literal defect: `clearOfferId: offerId == null` in `_emitQuote`
        // dropped the ONLY record that an offer had been in play, so the offer
        // could never come back for the rest of the session. Attribution still
        // goes — this sale did not come through the offer — but the offer itself
        // is remembered.
        final repo = RecordingBookingRepo();
        final cubit = buildCubit(repo);
        addTearDown(cubit.close);

        await cubit.applyOffer('offer-1');
        await cubit.applyPromoCode('OTHERCODE');

        expect(cubit.state.appliedPromoCode, 'OTHERCODE');
        expect(cubit.state.appliedOfferId, isNull);
        expect(cubit.state.rememberedOfferId, 'offer-1');
      },
    );

    test('a bare display re-quote decides nothing about the offer', () async {
      // `repriceForDisplayWithoutPromo` is the details screen's bare quote. It
      // says nothing about the offer's fate and must take nothing away.
      final repo = RecordingBookingRepo();
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await cubit.applyOffer('offer-1');
      await cubit.repriceForDisplayWithoutPromo();

      expect(cubit.state.rememberedOfferId, 'offer-1');
      expect(cubit.state.appliedOfferId, 'offer-1');
    });

    test('an offer the summary RE-QUOTE refuses is forgotten', () async {
      // The second way a refusal reaches the customer: the offer applied
      // cleanly on the way in, and the cap was consumed before they came back.
      // `reprice` drops the dead code — and with it the offer, which the
      // summary must not keep offering back into the same rejection.
      var offerStillLive = true;
      final repo = RecordingBookingRepo(
        quoteFailure: (_, offerId) {
          if (offerId == null) return null;
          if (offerStillLive) {
            offerStillLive = false;
            return null;
          }
          return const ServerFailure(
            'This code is no longer valid',
            type: FailureType.validation,
          );
        },
      );
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await cubit.applyOffer('offer-1');
      expect(cubit.state.rememberedOfferId, 'offer-1');

      await cubit.reprice();

      expect(cubit.state.rememberedOfferId, isNull);
    });

    test('an unanswered summary re-quote forgets nothing', () async {
      var offerStillLive = true;
      final repo = RecordingBookingRepo(
        quoteFailure: (_, offerId) {
          if (offerId == null) return null;
          if (offerStillLive) {
            offerStillLive = false;
            return null;
          }
          return const ServerFailure('No internet connection');
        },
      );
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await cubit.applyOffer('offer-1');
      await cubit.reprice();

      expect(
        cubit.state.rememberedOfferId,
        'offer-1',
        reason:
            'a timeout is not a verdict — the same discipline that guards '
            'the two display figures',
      );
    });
  });

  group('restoring', () {
    testWidgets('tapping the card re-applies the offer by id alone', (
      tester,
    ) async {
      final repo = RecordingBookingRepo();
      holdOffer('offer-1');
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      await tester.tap(removeCode);
      await settle(tester);

      await tester.tap(reapplyCard);
      await settle(tester);

      expect(cubit.state.appliedOfferId, 'offer-1');
      expect(cubit.state.appliedPromoCode, offerResolvedPromoCode);
      expect(reapplyCard, findsNothing);

      // The wire rule: an offer travels as an id, never alongside a code —
      // the pair is a 400.
      expect(repo.offerCalls.last, 'offer-1');
      expect(
        repo.quoteCalls.last,
        isNull,
        reason: 'sending promoCode and offerId together is a server 400',
      );
    });

    testWidgets('nothing re-applies on its own', (tester) async {
      final repo = RecordingBookingRepo();
      holdOffer('offer-1');
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      final beforeRemoval = repo.quoteCalls.length;
      await tester.tap(removeCode);
      await settle(tester);

      expect(
        repo.quoteCalls.length,
        beforeRemoval + 1,
        reason:
            'exactly the bare re-quote the removal asked for — a silent '
            're-price the customer did not ask for is worse than an offer to '
            'restore one',
      );
      expect(cubit.state.appliedOfferId, isNull);
    });

    testWidgets('an offer the server REFUSES on re-apply is forgotten', (
      tester,
    ) async {
      // The cap was consumed while the customer was typing. The refusal is a
      // VERDICT, so there is nothing left to offer back.
      var offerStillLive = true;
      final repo = RecordingBookingRepo(
        quoteFailure: (_, offerId) {
          if (offerId == null) return null;
          if (offerStillLive) {
            offerStillLive = false;
            return null;
          }
          return const ServerFailure(
            'This code is no longer valid',
            type: FailureType.validation,
          );
        },
      );
      holdOffer('offer-1');
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      await tester.tap(removeCode);
      await settle(tester);
      expect(reapplyCard, findsOneWidget);

      await tester.tap(reapplyCard);
      await settle(tester);

      expect(cubit.state.rememberedOfferId, isNull);
      expect(
        reapplyCard,
        findsNothing,
        reason:
            'a settled refusal ends the offer — a card that re-runs the '
            'same rejection forever is a dead button',
      );
    });

    testWidgets('a transport failure on re-apply forgets nothing', (
      tester,
    ) async {
      // No network / a timeout / a 5xx says nothing at all about the offer.
      // Dropping it here would take a deal away over a connection blip.
      var offerStillLive = true;
      final repo = RecordingBookingRepo(
        quoteFailure: (_, offerId) {
          if (offerId == null) return null;
          if (offerStillLive) {
            offerStillLive = false;
            return null;
          }
          return const ServerFailure('No internet connection');
        },
      );
      holdOffer('offer-1');
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      await tester.tap(removeCode);
      await settle(tester);

      await tester.tap(reapplyCard);
      await settle(tester);

      expect(cubit.state.appliedOfferId, isNull);
      expect(
        cubit.state.rememberedOfferId,
        'offer-1',
        reason:
            'the server never answered, so the offer is still the '
            "customer's to take",
      );
      expect(reapplyCard, findsOneWidget);
    });
  });

  group('the card names the offer', () {
    testWidgets('it carries the offer title when the flow was given one', (
      tester,
    ) async {
      final repo = RecordingBookingRepo();
      holdOffer('offer-1');
      final cubit = buildCubit(
        repo,
        offerTitleAr: 'عرض الافتتاح',
        offerTitleEn: 'Launch Offer',
      );
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      await tester.tap(removeCode);
      await settle(tester);

      // The title rode the offer detail screen's args into the state and out
      // to the card. (The label itself resolves to a raw key under this
      // harness, so the NAMED key being chosen over the generic one is what
      // proves the title arrived.)
      // Arabic, because `context.isAr` reads the LanguageCubit — which starts
      // in Arabic, the product's default locale — and not the widget locale.
      // Both titles ride the state, so the card renames with the language.
      expect(
        tester
            .widget<PromoCodeSection>(find.byType(PromoCodeSection))
            .reapplyOfferTitle,
        'عرض الافتتاح',
      );
      expect(find.text('bookings.reapply_offer'), findsOneWidget);
      expect(find.text('bookings.reapply_offer_generic'), findsNothing);
    });

    testWidgets('it falls back to generic copy with no title', (tester) async {
      final repo = RecordingBookingRepo();
      holdOffer('offer-1');
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      await tester.tap(removeCode);
      await settle(tester);

      expect(find.text('bookings.reapply_offer_generic'), findsOneWidget);
    });
  });

  group('a completed booking does not carry an offer forward', () {
    testWidgets('starting a fresh flow forgets the offer', (tester) async {
      final repo = RecordingBookingRepo();
      holdOffer('offer-1');
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await pumpSummary(tester, cubit);
      expect(cubit.state.rememberedOfferId, 'offer-1');

      // initBooking is the flow restart — a brand new state, so nothing of the
      // previous booking's offer can leak into this one.
      cubit.initBooking(service, existingCar: car, existingAddress: address);
      expect(cubit.state.rememberedOfferId, isNull);
    });
  });
}
