import 'dart:async';

import 'package:aqua_go/core/components/currency_amount.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/route/app_router.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/utils/saudi_wire_format.dart';
import 'package:aqua_go/features/home/data/data_source/services_remote_data_source.dart';
import 'package:aqua_go/features/home/data/models/service_model.dart';
import 'package:aqua_go/features/home/data/repos/services_repository.dart';
import 'package:aqua_go/features/offers/data/models/customer_offer_model.dart';
import 'package:aqua_go/features/offers/domain/pending_promo_code.dart';
import 'package:aqua_go/features/offers/presentation/controllers/offers_controller/offers_cubit.dart';
import 'package:aqua_go/features/offers/presentation/views/offer_detail_view.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/offers_harness.dart';

/// A [ServicesRepository] whose one read is scripted, and optionally HELD OPEN
/// so a test can tap again while the fetch is still in flight.
class ScriptedServicesRepository extends ServicesRepository {
  ScriptedServicesRepository({Either<Failure, List<ServiceModel>>? result})
      : _result = result ?? const Right(<ServiceModel>[]),
        super(ServicesRemoteDataSource(APIClient(Dio())));

  final Either<Failure, List<ServiceModel>> _result;

  int calls = 0;

  /// Non-null while a test is deliberately stalling the fetch.
  Completer<void>? gate;

  @override
  Future<Either<Failure, List<ServiceModel>>> fetchServices() async {
    calls++;
    if (gate != null) await gate!.future;
    return _result;
  }
}

/// A SERVICE offer. `targetPriceMinor: 0` makes it a SHORTCUT card — a
/// deep-link into booking the wash at its list price, with no deal at all.
CustomerOfferModel serviceOffer({
  String id = 'offer-svc',
  String? serviceId = 'svc-1',
  int targetPriceMinor = 3500,
}) =>
    CustomerOfferModel.fromJson({
      'id': id,
      'offerType': 'SERVICE',
      'titleAr': 'غسيل كامل',
      'titleEn': 'Full wash',
      'descriptionAr': 'وصف',
      'descriptionEn': 'Description',
      'endsAt': toWireDateTime(saudiNow().add(const Duration(days: 30))),
      'terms': {
        'serviceId': ?serviceId,
        'serviceNameAr': 'غسيل كامل',
        'serviceNameEn': 'Full wash',
        'serviceListPriceMinor': 17500,
        'targetPriceMinor': targetPriceMinor,
      },
    });

/// A promo-code offer whose discount is a flat amount — the one term whose
/// English wording puts the money MID-SENTENCE ("20.00 off").
CustomerOfferModel fixedAmountPromoOffer({int configuredValue = 2000}) =>
    CustomerOfferModel(
      id: 'offer-flat',
      offerType: 'PROMO_CODE',
      titleAr: 'خصم ثابت',
      titleEn: 'Flat discount',
      descriptionAr: 'وصف',
      descriptionEn: 'Description',
      endsAt: saudiNow().add(const Duration(days: 30)),
      terms: OfferTermsModel(
        promoCode: 'FLAT20',
        discountType: 'FIXED_AMOUNT',
        configuredValue: configuredValue,
      ),
    );

const ServiceModel _fullWash = ServiceModel(id: 'svc-1', code: 'FULL');

void main() {
  late ScriptedOffersRepository repo;
  late ScriptedServicesRepository servicesRepo;
  late List<RouteSettings> pushed;

  Route<dynamic> recorder(RouteSettings settings) {
    pushed.add(settings);
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => const Scaffold(body: Text('elsewhere')),
    );
  }

  setUp(() async {
    await bootOffersTestEnvironment();
    pushed = <RouteSettings>[];
    servicesRepo = ScriptedServicesRepository(result: const Right([_fullWash]));
    // `OfferDetailView` is pushed inline from the offers list, inside the
    // OffersCubit subtree — it is NOT a named route, so there is no router
    // entry to hang providers off. The service lookup therefore goes through
    // the locator, which is what this registers.
    locator.registerLazySingleton<ServicesRepository>(() => servicesRepo);
    // The handoff is a process-wide single-shot slot, and `takeHandoff` is the
    // only way to empty it — DESTRUCTIVE, so it is drained on the way OUT too,
    // or one test's held offer leaks into the next test's assertions.
    PendingPromoCode.instance.takeHandoff();
    addTearDown(PendingPromoCode.instance.takeHandoff);
  });

  tearDown(() async {
    await locator.reset();
  });

  OffersCubit cubitFor(ScriptedOffersRepository r) =>
      OffersCubit(offersRepository: r);

  Future<void> tapPrimaryAction(WidgetTester tester) async {
    final action = find.byKey(const ValueKey('offer-primary-action'));
    await tester.ensureVisible(action);
    await tester.pump();
    await tester.tap(action);
  }

  Future<void> pumpDetail(WidgetTester tester, CustomerOfferModel offer) async {
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
  }

  group('OfferDetailView — the SERVICE offer', () {
    // AQG-439. The SERVICE action is gated behind sign-in — the booking flow
    // it deep-links into is authenticated end to end. `bootOffersTestEnvironment`
    // leaves `currentUser` null, i.e. a GUEST, so every case in this group that
    // asserts on what happens AFTER the tap has to say who is tapping. The
    // guest's own path is covered by `offer_guest_gate_test.dart`.
    setUp(signIn);

    testWidgets('labels its primary action "Book now"', (tester) async {
      await pumpDetail(tester, serviceOffer());
      expect(find.text(LocaleKeys.offers_book_now.tr()), findsOneWidget);
      // Not the promo or package wording — a SERVICE offer books a wash.
      expect(find.text(LocaleKeys.offers_use_code.tr()), findsNothing);
      expect(find.text(LocaleKeys.offers_view_package.tr()), findsNothing);
    });

    testWidgets('states the wash and both prices under "Offer details"',
        (tester) async {
      // The terms block used to be a heading over an expiry row: the SERVICE
      // third of `OfferTerms` shares no field with the package third, so the
      // offer fell through the package tail and emitted nothing.
      await pumpDetail(tester, serviceOffer());

      expect(find.text('Full wash'), findsWidgets);
      // The currency is the riyal GLYPH, not the word "SAR" — the same currency
      // the booking price breakdown draws. [glyphSlot] marks where it sits, so
      // these read the wording AND the glyph's position in one assertion.
      expect(find.text('Original price 175.00$glyphSlot'), findsOneWidget);
      final struck =
          tester.widget<Text>(find.text('Original price 175.00$glyphSlot'));
      expect(struck.style?.decoration, TextDecoration.lineThrough);
      expect(find.text('Offer price 35.00$glyphSlot'), findsOneWidget);
      // Nothing on this screen spells the currency out any more.
      expect(find.textContaining('SAR'), findsNothing);
    });

    testWidgets('the strike crosses the glyph as well as the figure',
        (tester) async {
      // `TextDecoration.lineThrough` on the row's style does not reach inside a
      // WidgetSpan, so the superseded price used to be crossed out up to the
      // currency and no further. The glyph draws its own strike.
      await pumpDetail(tester, serviceOffer());

      CurrencyGlyph glyphIn(String rowText) => tester.widget<CurrencyGlyph>(
            find.descendant(
              of: find.text(rowText),
              matching: find.byType(CurrencyGlyph),
            ),
          );

      expect(glyphIn('Original price 175.00$glyphSlot').struckThrough, isTrue);
      // …and the price the customer actually pays is NOT crossed out.
      expect(glyphIn('Offer price 35.00$glyphSlot').struckThrough, isFalse);
    });

    testWidgets('a non-money term row carries no glyph at all', (tester) async {
      // The wash name is a literal row and the expiry is a keyed row with no
      // money in it; neither may sprout a currency.
      await pumpDetail(tester, serviceOffer(targetPriceMinor: 0));

      expect(find.byType(CurrencyGlyph), findsNothing);
      expect(find.text('Full wash'), findsWidgets);
      expect(find.textContaining('Offer ends on'), findsOneWidget);
    });

    testWidgets('a SHORTCUT offer prices nothing — 0 is no deal, not free',
        (tester) async {
      await pumpDetail(tester, serviceOffer(targetPriceMinor: 0));

      // Written against the WORDING rather than a `.tr()` of the money key: a
      // money row is a `Text.rich` whose plain text carries the glyph slot, so
      // a `find.text` built from `.tr(args:)` alone can no longer match one and
      // would pass here whether or not the row was drawn.
      expect(find.textContaining('Original price'), findsNothing);
      expect(find.textContaining('Offer price'), findsNothing);
    });

    testWidgets('opens the booking flow at the resolved service',
        (tester) async {
      await pumpDetail(tester, serviceOffer());

      await tapPrimaryAction(tester);
      await settleOffers(tester);

      expect(servicesRepo.calls, 1);
      expect(pushed.single.name, Routes.bookingLocation);
      final args = pushed.single.arguments as BookingFlowStartArgs;
      expect(args.service?.id, 'svc-1');
    });

    testWidgets('holds the OFFER, not the code, when it carries a deal',
        (tester) async {
      // The server resolves the managed code itself; a client-supplied code
      // carries no evidence of which offer produced the sale.
      await pumpDetail(tester, serviceOffer(targetPriceMinor: 3500));

      await tapPrimaryAction(tester);
      await settleOffers(tester);

      expect(PendingPromoCode.instance.takeHandoff()?.offerId, 'offer-svc');
    });

    testWidgets('a SHORTCUT offer holds nothing at all', (tester) async {
      // targetPriceMinor 0 is "no deal", not "free" — there is no code behind
      // this card, so holding the offer would send the quote chasing one.
      await pumpDetail(tester, serviceOffer(targetPriceMinor: 0));

      await tapPrimaryAction(tester);
      await settleOffers(tester);

      expect(pushed.single.name, Routes.bookingLocation);
      expect(PendingPromoCode.instance.takeHandoff(), isNull);
    });

    testWidgets('a second tap during the fetch does not double-navigate',
        (tester) async {
      // `_checking` used to be released BEFORE the action ran, so the button
      // re-enabled while the service lookup was still open and a second tap
      // fired a second navigation off one offer — exactly what the guard
      // exists to prevent.
      servicesRepo.gate = Completer<void>();
      await pumpDetail(tester, serviceOffer());

      await tapPrimaryAction(tester);
      // Let the re-validation round-trip resolve. The fetch is still open.
      await tester.pump();
      await tester.pump();
      await tapPrimaryAction(tester);

      servicesRepo.gate!.complete();
      await settleOffers(tester);

      expect(servicesRepo.calls, 1);
      expect(pushed.where((r) => r.name != null), hasLength(1));
    });

    testWidgets('an offer with no service behind it is blocked, not left dead',
        (tester) async {
      // `OfferTermsModel.fromJson` degrades a missing identity field to null
      // rather than throwing, so this is a supported input — and one with
      // nothing to act on.
      await pumpDetail(tester, serviceOffer(serviceId: null));

      await tapPrimaryAction(tester);
      await settleOffers(tester);

      expect(servicesRepo.calls, 0, reason: 'nothing to look up');
      expect(pushed.where((r) => r.name != null), isEmpty);
      expect(PendingPromoCode.instance.takeHandoff(), isNull);
    });

    testWidgets('a service the catalogue no longer carries is blocked',
        (tester) async {
      servicesRepo = ScriptedServicesRepository(
        result: const Right(<ServiceModel>[]),
      );
      await locator.unregister<ServicesRepository>();
      locator.registerLazySingleton<ServicesRepository>(() => servicesRepo);

      await pumpDetail(tester, serviceOffer());

      await tapPrimaryAction(tester);
      await settleOffers(tester);

      expect(servicesRepo.calls, 1);
      expect(pushed.where((r) => r.name != null), isEmpty);
      expect(PendingPromoCode.instance.takeHandoff(), isNull);
    });

    testWidgets('an unreachable services catalogue is blocked, not routed',
        (tester) async {
      servicesRepo = ScriptedServicesRepository(
        result: const Left(ServerFailure('timeout', type: FailureType.server)),
      );
      await locator.unregister<ServicesRepository>();
      locator.registerLazySingleton<ServicesRepository>(() => servicesRepo);

      await pumpDetail(tester, serviceOffer());

      await tapPrimaryAction(tester);
      await settleOffers(tester);

      expect(pushed.where((r) => r.name != null), isEmpty);
      expect(PendingPromoCode.instance.takeHandoff(), isNull);
    });
  });

  group('the currency is the riyal glyph, wherever the figure falls', () {
    Future<void> pumpPromo(
      WidgetTester tester, {
      Locale locale = const Locale('en'),
    }) async {
      final offer = fixedAmountPromoOffer();
      repo = ScriptedOffersRepository(
        listResult: Right([offer]),
        detailResult: Right(offer),
      );
      await pumpOffersSurface(
        tester,
        child: OfferDetailView(offer: offer),
        cubit: cubitFor(repo),
        locale: locale,
      );
    }

    testWidgets('it lands after the figure, not at the end of the sentence',
        (tester) async {
      // "{} off" is the case that makes appending the currency wrong: the money
      // is MID-string here and terminal in "Minimum order {}". [glyphSlot] is
      // asserted in position, so a glyph parked at the end fails.
      await pumpPromo(tester);

      expect(find.text('20.00$glyphSlot off'), findsOneWidget);
      expect(find.text('20.00 off$glyphSlot'), findsNothing);
      expect(find.textContaining('SAR'), findsNothing);
    });

    testWidgets('Arabic states the same figure with the same glyph, no word',
        (tester) async {
      await pumpPromo(tester, locale: const Locale('ar'));

      // Same span ORDER as the English row — figure, then glyph — and Flutter
      // lays it out RTL from that; nothing in the widget branches on direction.
      // (The RTL layout itself is pinned in offers_surface_test.dart.)
      expect(find.text('خصم 20.00$glyphSlot'), findsOneWidget);
      expect(find.textContaining('ريال'), findsNothing);
    });
  });
}
