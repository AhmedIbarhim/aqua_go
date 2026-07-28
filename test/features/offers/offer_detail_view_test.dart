import 'dart:async';

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
      expect(
        find.text(LocaleKeys.offers_service_list_price.tr(args: ['175.00'])),
        findsOneWidget,
      );
      final struck = tester.widget<Text>(
        find.text(LocaleKeys.offers_service_list_price.tr(args: ['175.00'])),
      );
      expect(struck.style?.decoration, TextDecoration.lineThrough);
      expect(
        find.text(LocaleKeys.offers_service_price.tr(args: ['35.00'])),
        findsOneWidget,
      );
    });

    testWidgets('a SHORTCUT offer prices nothing — 0 is no deal, not free',
        (tester) async {
      await pumpDetail(tester, serviceOffer(targetPriceMinor: 0));

      expect(
        find.text(LocaleKeys.offers_service_list_price.tr(args: ['175.00'])),
        findsNothing,
      );
      expect(
        find.text(LocaleKeys.offers_service_price.tr(args: ['0.00'])),
        findsNothing,
      );
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
}
