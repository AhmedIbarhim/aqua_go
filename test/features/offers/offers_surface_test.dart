import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/helpers/shimmer_helper.dart';
import 'package:aqua_go/core/route/app_router.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/features/home/presentation/widgets/offers_list_view.dart';
import 'package:aqua_go/features/offers/data/models/customer_offer_model.dart';
import 'package:aqua_go/core/utils/saudi_wire_format.dart';
import 'package:aqua_go/features/offers/domain/pending_promo_code.dart';
import 'package:aqua_go/features/offers/presentation/controllers/offers_controller/offers_cubit.dart';
import 'package:aqua_go/features/offers/presentation/views/offer_detail_view.dart';
import 'package:aqua_go/features/offers/presentation/views/offers_view.dart';
import 'package:aqua_go/features/offers/presentation/widgets/offer_card.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:dartz/dartz.dart';
// `intl` (re-exported by easy_localization) ships its own TextDirection, which
// would shadow the dart:ui one the Directionality assertions need.
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/offers_harness.dart';

void main() {
  late ScriptedOffersRepository repo;

  setUp(() async {
    await bootOffersTestEnvironment();
  });

  tearDown(() async {
    await locator.reset();
  });

  OffersCubit cubitFor(ScriptedOffersRepository r) =>
      OffersCubit(offersRepository: r);

  group('UCC23 A6 — the offers screen distinguishes empty, error and loading', () {
    testWidgets('an outage offers a RETRY, not an empty list', (tester) async {
      repo = ScriptedOffersRepository(
        listResult: const Left(ServerFailure('down', type: FailureType.server)),
      );
      final cubit = cubitFor(repo);
      await pumpOffersSurface(tester, child: const OffersView(), cubit: cubit);
      await cubit.getOffers();
      await tester.pump();

      // A6: "a retry state rather than an empty list, so an outage is not
      // mistaken for 'no offers'."
      expect(find.byKey(const ValueKey('offers-retry')), findsOneWidget);
      expect(find.text(LocaleKeys.offers_error.tr()), findsOneWidget);
      expect(find.text(LocaleKeys.offers_empty.tr()), findsNothing);
    });

    testWidgets('the retry button re-fetches, and a recovered feed renders', (tester) async {
      repo = ScriptedOffersRepository(
        listResult: const Left(ServerFailure('down', type: FailureType.server)),
      );
      final cubit = cubitFor(repo);
      await pumpOffersSurface(tester, child: const OffersView(), cubit: cubit);
      await cubit.getOffers();
      await tester.pump();
      expect(repo.listCalls, 1);

      repo.answerListWith(Right([promoOffer()]));
      await tester.tap(find.byKey(const ValueKey('offers-retry')));
      await tester.pump();
      await tester.pump();

      expect(repo.listCalls, 2, reason: 'retry must hit the network again');
      expect(find.byKey(const ValueKey('offers-retry')), findsNothing);
      expect(find.text('Welcome offer'), findsOneWidget);
    });

    testWidgets('a genuinely empty feed says so and offers NO retry', (tester) async {
      repo = ScriptedOffersRepository(listResult: const Right(<CustomerOfferModel>[]));
      final cubit = cubitFor(repo);
      await pumpOffersSurface(tester, child: const OffersView(), cubit: cubit);
      await cubit.getOffers();
      await tester.pump();

      // A1 — an empty state, not an error. Offering "retry" here would tell the
      // customer something went wrong when nothing did.
      expect(find.text(LocaleKeys.offers_empty.tr()), findsOneWidget);
      expect(find.byKey(const ValueKey('offers-retry')), findsNothing);
      // A1 also asks for "an illustration AND the line" — the line alone reads
      // as a screen that failed to draw rather than as a finished state.
      expect(find.byKey(const ValueKey('offers-empty-art')), findsOneWidget);
    });

    testWidgets('loading is a third state, neither empty nor error', (tester) async {
      repo = ScriptedOffersRepository(listResult: const Right(<CustomerOfferModel>[]));
      await pumpOffersSurface(tester, child: const OffersView(), cubit: cubitFor(repo));

      // A skeleton, and neither of the other two states — a customer waiting on
      // a slow feed must not be told there are no offers, nor that one failed.
      expect(find.byKey(const ValueKey('offers-loading')), findsOneWidget);
      expect(find.byType(ShimmerHelper), findsWidgets);
      expect(find.text(LocaleKeys.offers_empty.tr()), findsNothing);
      expect(find.byKey(const ValueKey('offers-retry')), findsNothing);
      expect(find.byKey(const ValueKey('offers-empty-art')), findsNothing);
    });
  });

  group('UCC23 A6 — the home rail keeps the same three states', () {
    testWidgets('an outage leaves a retry on the rail instead of hiding it', (tester) async {
      repo = ScriptedOffersRepository(
        listResult: const Left(ServerFailure('down', type: FailureType.server)),
      );
      final cubit = cubitFor(repo);
      await pumpOffersSurface(
        tester,
        child: const Scaffold(body: OffersListView()),
        cubit: cubit,
      );
      await cubit.getOffers();
      await tester.pump();

      // The rail used to render SizedBox.shrink() here, which is invisible: the
      // customer cannot tell an outage from "no offers" and cannot retry it.
      expect(find.byKey(const ValueKey('home-offers-retry')), findsOneWidget);
    });

    testWidgets('the rail retry re-fetches and then shows the offers', (tester) async {
      repo = ScriptedOffersRepository(
        listResult: const Left(ServerFailure('down', type: FailureType.server)),
      );
      final cubit = cubitFor(repo);
      await pumpOffersSurface(
        tester,
        child: const Scaffold(body: OffersListView()),
        cubit: cubit,
      );
      await cubit.getOffers();
      await tester.pump();

      repo.answerListWith(Right([promoOffer()]));
      await tester.tap(find.byKey(const ValueKey('home-offers-retry')));
      await tester.pump();
      await tester.pump();

      expect(repo.listCalls, 2);
      expect(find.byType(OfferCard), findsOneWidget);
    });

    testWidgets('a genuinely empty feed still hides the rail entirely', (tester) async {
      repo = ScriptedOffersRepository(listResult: const Right(<CustomerOfferModel>[]));
      final cubit = cubitFor(repo);
      await pumpOffersSurface(
        tester,
        child: const Scaffold(body: OffersListView()),
        cubit: cubit,
      );
      await cubit.getOffers();
      await tester.pump();

      expect(find.byKey(const ValueKey('home-offers-retry')), findsNothing);
      expect(find.byType(OfferCard), findsNothing);
      expect(find.text(LocaleKeys.home_best_offers.tr()), findsNothing);
    });
  });

  group('UCC23 step 6 — the home rail opens the offer that was tapped', () {
    testWidgets('a promo card opens ITS detail, not the unfiltered list', (tester) async {
      // The rail renders soonest-closing first, so the offer the repository
      // returns SECOND is the one drawn first. Tapping the leading card must
      // therefore open 'wanted' — which also proves the tap follows what the
      // customer sees rather than the order the feed arrived in.
      final tapped = promoOffer(
        id: 'wanted',
        code: 'WANTED10',
        endsAt: saudiNow().add(const Duration(days: 3)),
      );
      repo = ScriptedOffersRepository(
        listResult: Right([
          promoOffer(
            id: 'other',
            code: 'OTHER',
            endsAt: saudiNow().add(const Duration(days: 20)),
          ),
          tapped,
        ]),
      );
      final cubit = cubitFor(repo);
      await pumpOffersSurface(
        tester,
        child: const Scaffold(body: OffersListView()),
        cubit: cubit,
      );
      await cubit.getOffers();
      await tester.pump();

      await tester.tap(find.text('Welcome offer').first);
      await tester.pumpAndSettle();

      final detail = tester.widget<OfferDetailView>(find.byType(OfferDetailView));
      expect(detail.offer.id, 'wanted');
      expect(find.byType(OffersView), findsNothing);
    });

    testWidgets('a package card opens the detail too, not the catalogue directly',
        (tester) async {
      // The primary action inside the detail is what routes to the package —
      // going straight there skips the terms and the A2 re-validation.
      repo = ScriptedOffersRepository(listResult: Right([packageOffer()]));
      final cubit = cubitFor(repo);
      await pumpOffersSurface(
        tester,
        child: const Scaffold(body: OffersListView()),
        cubit: cubit,
      );
      await cubit.getOffers();
      await tester.pump();

      await tester.tap(find.text('Gold package').first);
      await tester.pumpAndSettle();

      expect(find.byType(OfferDetailView), findsOneWidget);
    });
  });

  group('UCC23 step 6/7 + A2 — the detail view and its primary action', () {
    /// Records every named push so a test can assert WHERE the primary action
    /// took the customer, without dragging the real router in.
    late List<RouteSettings> pushed;

    Route<dynamic> recorder(RouteSettings settings) {
      pushed.add(settings);
      return MaterialPageRoute<dynamic>(
        settings: settings,
        builder: (_) => const Scaffold(body: Text('elsewhere')),
      );
    }

    setUp(() {
      pushed = <RouteSettings>[];
      // The handoff is a process-wide single-shot slot; draining it keeps one
      // test's held offer out of the next test's assertions.
      PendingPromoCode.instance.takeHandoff();
    });

    testWidgets('the terms state the expiry date, in the reader\'s language',
        (tester) async {
      // UCC23 step 6 — "terms (minimum order value, applicable services,
      // applicable zones, expiry)". The date used to sit in the summary and was
      // then dropped from it; it belongs in the terms block either way.
      final offer = promoOffer(endsAt: DateTime.utc(2026, 12, 31, 20, 59, 59));
      repo = ScriptedOffersRepository(listResult: Right([offer]));
      await pumpOffersSurface(
        tester,
        child: OfferDetailView(offer: offer),
        cubit: cubitFor(repo),
      );

      final en = DateFormat.yMMMd('en').format(offer.endsAt.toLocal());
      expect(
        find.text(LocaleKeys.offers_expires_on.tr(args: [en])),
        findsOneWidget,
      );
    });

    testWidgets('the expiry date is written in Arabic for an Arabic reader',
        (tester) async {
      final offer = promoOffer(endsAt: DateTime.utc(2026, 12, 31, 20, 59, 59));
      repo = ScriptedOffersRepository(listResult: Right([offer]));
      await pumpOffersSurface(
        tester,
        child: OfferDetailView(offer: offer),
        cubit: cubitFor(repo),
        locale: const Locale('ar'),
      );

      final ar = DateFormat.yMMMd('ar').format(offer.endsAt.toLocal());
      expect(
        find.text(LocaleKeys.offers_expires_on.tr(args: [ar])),
        findsOneWidget,
      );
      // The date is never wrapped in an LTR island: it is Arabic text in an
      // Arabic sentence and belongs to the paragraph's direction.
      expect(Directionality.of(tester.element(find.byType(OfferDetailView))),
          TextDirection.rtl);
    });

    testWidgets('the terms state the applicable services and zones', (tester) async {
      final offer = restrictedPromoOffer();
      repo = ScriptedOffersRepository(listResult: Right([offer]));
      await pumpOffersSurface(
        tester,
        child: OfferDetailView(offer: offer),
        cubit: cubitFor(repo),
      );

      expect(
        find.text(LocaleKeys.offers_applicable_services.tr(args: ['Premium Wash'])),
        findsOneWidget,
      );
      expect(
        find.text(LocaleKeys.offers_applicable_zones.tr(args: ['Central Jeddah'])),
        findsOneWidget,
      );
    });

    testWidgets('A2 — an offer that died while being read is blocked and the list refreshed',
        (tester) async {
      final offer = promoOffer();
      repo = ScriptedOffersRepository(
        listResult: Right([offer]),
        detailResult: const Left(ServerFailure('gone', type: FailureType.notFound)),
      );
      final cubit = cubitFor(repo);
      await pumpOffersSurface(tester, child: const OffersView(), cubit: cubit);
      await cubit.getOffers();
      await tester.pump();
      await tester.tap(find.text('Welcome offer'));
      await tester.pumpAndSettle();
      expect(find.byType(OfferDetailView), findsOneWidget);

      repo.answerListWith(const Right(<CustomerOfferModel>[]));
      await tester.tap(find.byKey(const ValueKey('offer-primary-action')));
      await tester.pumpAndSettle();

      // "the system re-validates, blocks the action and returns the customer to
      // a refreshed list with a brief toast."
      expect(repo.detailCalls, ['offer-1']);
      expect(repo.listCalls, 2, reason: 'the list behind the detail is refreshed');
      expect(find.byType(OfferDetailView), findsNothing);
      expect(find.text(LocaleKeys.offers_expired.tr()), findsOneWidget);
      expect(PendingPromoCode.instance.takeHandoff(), isNull,
          reason: 'a dead offer must not be carried into the booking flow');
    });

    testWidgets('a live offer hands the OFFER, not just the code, to the booking flow',
        (tester) async {
      // UCC23 step 7 — "the code is … pre-applied to the customer's next quote
      // … the customer is taken into the booking flow." The offer id rides
      // along because two live offers may carry one code (UCA22 A6).
      final offer = promoOffer(id: 'offer-live', code: 'WELCOME20');
      repo = ScriptedOffersRepository(
        listResult: Right([offer]),
        detailResult: Right(offer),
      );
      await pumpOffersSurface(
        tester,
        child: OfferDetailView(offer: offer),
        cubit: cubitFor(repo),
        onGenerateRoute: recorder,
      );

      await tester.tap(find.byKey(const ValueKey('offer-primary-action')));
      await tester.pumpAndSettle();

      final held = PendingPromoCode.instance.takeHandoff();
      expect(held?.offerId, 'offer-live');
      expect(held?.promoCode, 'WELCOME20');
      expect(pushed.single.name, Routes.layout);
    });

    testWidgets('the re-validated copy supersedes the one the list drew', (tester) async {
      // The list handed over a stale copy; the server's answer is authoritative.
      final stale = promoOffer(id: 'offer-live', code: 'OLDCODE');
      final fresh = promoOffer(id: 'offer-live', code: 'NEWCODE');
      repo = ScriptedOffersRepository(
        listResult: Right([stale]),
        detailResult: Right(fresh),
      );
      await pumpOffersSurface(
        tester,
        child: OfferDetailView(offer: stale),
        cubit: cubitFor(repo),
        onGenerateRoute: recorder,
      );

      await tester.tap(find.byKey(const ValueKey('offer-primary-action')));
      await tester.pumpAndSettle();

      expect(PendingPromoCode.instance.takeHandoff()?.promoCode, 'NEWCODE');
    });

    testWidgets('an unreachable server is not treated as an expiry', (tester) async {
      // BR-OFR-11 puts the real gate at apply time. A flaky connection must not
      // read to the customer as "your offer is gone".
      final offer = promoOffer(id: 'offer-live', code: 'WELCOME20');
      repo = ScriptedOffersRepository(
        listResult: Right([offer]),
        detailResult: const Left(ServerFailure('timeout', type: FailureType.server)),
      );
      await pumpOffersSurface(
        tester,
        child: OfferDetailView(offer: offer),
        cubit: cubitFor(repo),
        onGenerateRoute: recorder,
      );

      await tester.tap(find.byKey(const ValueKey('offer-primary-action')));
      await tester.pumpAndSettle();

      expect(repo.listCalls, 0, reason: 'nothing died, so nothing to refresh');
      expect(PendingPromoCode.instance.takeHandoff()?.promoCode, 'WELCOME20');
      expect(pushed.single.name, Routes.layout);
    });

    testWidgets('a package offer opens the linked package, holding no code', (tester) async {
      // UCC23 step 7, package half — "the customer is taken to the linked
      // package in the subscription catalogue (UC-C13)".
      final offer = packageOffer(packageId: 'pkg-77');
      repo = ScriptedOffersRepository(
        listResult: Right([offer]),
        detailResult: Right(offer),
      );
      await pumpOffersSurface(
        tester,
        child: OfferDetailView(offer: offer),
        cubit: cubitFor(repo),
        onGenerateRoute: recorder,
      );

      await tester.tap(find.byKey(const ValueKey('offer-primary-action')));
      await tester.pumpAndSettle();

      expect(pushed.single.name, Routes.packageDetail);
      expect((pushed.single.arguments as PackageDetailArgs).packageId, 'pkg-77');
      expect(PendingPromoCode.instance.takeHandoff(), isNull);
    });
  });

  group('UCC23 A4 — the sign-in prompt', () {
    testWidgets('a guest is told more offers may be available once signed in',
        (tester) async {
      repo = ScriptedOffersRepository(listResult: const Right(<CustomerOfferModel>[]));
      final cubit = cubitFor(repo);
      await pumpOffersSurface(tester, child: const OffersView(), cubit: cubit);
      await cubit.getOffers();
      await tester.pump();

      expect(find.byKey(const ValueKey('offers-sign-in-prompt')), findsOneWidget);
      expect(find.text(LocaleKeys.offers_sign_in_prompt.tr()), findsOneWidget);
    });

    testWidgets('a signed-in customer is not nagged', (tester) async {
      signIn();
      repo = ScriptedOffersRepository(listResult: Right([promoOffer()]));
      final cubit = cubitFor(repo);
      await pumpOffersSurface(tester, child: const OffersView(), cubit: cubit);
      await cubit.getOffers();
      await tester.pump();

      expect(find.byKey(const ValueKey('offers-sign-in-prompt')), findsNothing);
    });

    testWidgets('the prompt survives the empty state, where it matters most',
        (tester) async {
      repo = ScriptedOffersRepository(listResult: const Right(<CustomerOfferModel>[]));
      final cubit = cubitFor(repo);
      await pumpOffersSurface(tester, child: const OffersView(), cubit: cubit);
      await cubit.getOffers();
      await tester.pump();

      // "No offers available" plus nothing else would read as "Aqua Go has no
      // offers" when in fact the guest is only being served the anonymous
      // subset (BR-OFR-01/-02/-03 evaluated, -04..-09 unevaluable).
      expect(find.text(LocaleKeys.offers_empty.tr()), findsOneWidget);
      expect(find.byKey(const ValueKey('offers-sign-in-prompt')), findsOneWidget);
    });
  });

  group('AC-EXT-08 — the banner and layout follow the app language', () {
    testWidgets('Arabic renders the AR banner in an RTL layout', (tester) async {
      repo = ScriptedOffersRepository(listResult: Right([promoOffer()]));
      final cubit = cubitFor(repo);
      await pumpOffersSurface(
        tester,
        child: const OffersView(),
        cubit: cubit,
        locale: const Locale('ar'),
      );
      await cubit.getOffers();
      await tester.pump();

      expect(find.text('عرض الترحيب'), findsOneWidget);
      expect(find.text('Welcome offer'), findsNothing);
      expect(
        Directionality.of(tester.element(find.byType(OfferCard))),
        TextDirection.rtl,
      );
      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      expect(
        images.map((i) => (i.image as NetworkImage).url),
        contains('https://cdn.example/offer-1-ar.png'),
      );
    });

    testWidgets('English renders the EN banner in an LTR layout', (tester) async {
      repo = ScriptedOffersRepository(listResult: Right([promoOffer()]));
      final cubit = cubitFor(repo);
      await pumpOffersSurface(
        tester,
        child: const OffersView(),
        cubit: cubit,
        locale: const Locale('en'),
      );
      await cubit.getOffers();
      await tester.pump();

      expect(find.text('Welcome offer'), findsOneWidget);
      expect(find.text('عرض الترحيب'), findsNothing);
      expect(
        Directionality.of(tester.element(find.byType(OfferCard))),
        TextDirection.ltr,
      );
      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      expect(
        images.map((i) => (i.image as NetworkImage).url),
        contains('https://cdn.example/offer-1-en.png'),
      );
    });
  });

  group('BR-OFR-10 / AC-EXT-06 — the threshold reaches the card', () {
    testWidgets('a minimum order is stated on the list card', (tester) async {
      repo = ScriptedOffersRepository(
        listResult: Right([promoOffer(minOrderMinor: 10000)]),
      );
      final cubit = cubitFor(repo);
      await pumpOffersSurface(tester, child: const OffersView(), cubit: cubit);
      await cubit.getOffers();
      await tester.pump();

      expect(find.text(LocaleKeys.offers_min_order.tr(args: ['100.00'])), findsOneWidget);
    });

    testWidgets('a minimum order is stated on the HOME RAIL card too', (tester) async {
      // The rail is a real route into the booking flow, so a customer can reach
      // the refusal from here without ever opening the offers screen.
      repo = ScriptedOffersRepository(
        listResult: Right([promoOffer(minOrderMinor: 7550)]),
      );
      final cubit = cubitFor(repo);
      await pumpOffersSurface(
        tester,
        child: const Scaffold(body: OffersListView()),
        cubit: cubit,
      );
      await cubit.getOffers();
      await tester.pump();

      expect(find.text(LocaleKeys.offers_min_order.tr(args: ['75.50'])), findsOneWidget);
    });

    testWidgets('an unrestricted offer states no threshold', (tester) async {
      repo = ScriptedOffersRepository(listResult: Right([promoOffer()]));
      final cubit = cubitFor(repo);
      await pumpOffersSurface(tester, child: const OffersView(), cubit: cubit);
      await cubit.getOffers();
      await tester.pump();

      expect(find.textContaining('Minimum order'), findsNothing);
    });
  });
}
