import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/config/session/session_state.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/utils/saudi_wire_format.dart';
import 'package:aqua_go/features/home/data/data_source/services_remote_data_source.dart';
import 'package:aqua_go/features/home/data/models/service_model.dart';
import 'package:aqua_go/features/home/data/repos/services_repository.dart';
import 'package:aqua_go/features/offers/data/models/customer_offer_model.dart';
import 'package:aqua_go/features/offers/presentation/controllers/offers_controller/offers_cubit.dart';
import 'package:aqua_go/features/offers/presentation/views/offer_detail_view.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/offers_harness.dart';

/// A [ServicesRepository] that answers one wash and counts its reads.
class CountingServicesRepository extends ServicesRepository {
  CountingServicesRepository()
      : super(ServicesRemoteDataSource(APIClient(Dio())));

  int calls = 0;

  @override
  Future<Either<Failure, List<ServiceModel>>> fetchServices() async {
    calls++;
    return const Right(<ServiceModel>[]);
  }
}

CustomerOfferModel serviceOffer() => CustomerOfferModel.fromJson({
      'id': 'offer-svc',
      'offerType': 'SERVICE',
      'titleAr': 'غسيل كامل',
      'titleEn': 'Full wash',
      'descriptionAr': 'وصف',
      'descriptionEn': 'Description',
      'endsAt': toWireDateTime(saudiNow().add(const Duration(days: 30))),
      'terms': {
        'serviceId': 'svc-1',
        'serviceNameAr': 'غسيل كامل',
        'serviceNameEn': 'Full wash',
        'serviceListPriceMinor': 17500,
        'targetPriceMinor': 3500,
      },
    });

void main() {
  late List<RouteSettings> pushed;
  late CountingServicesRepository servicesRepo;

  Route<dynamic>? recorder(RouteSettings settings) {
    pushed.add(settings);
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const Scaffold(body: Text('elsewhere')),
    );
  }

  setUp(() async {
    await bootOffersTestEnvironment(); // leaves currentUser null == guest
    pushed = <RouteSettings>[];
    servicesRepo = CountingServicesRepository();
    locator.registerLazySingleton<ServicesRepository>(() => servicesRepo);
  });

  tearDown(() async {
    currentUser.value = null;
    await locator.reset();
  });

  Future<void> pumpDetail(WidgetTester tester) async {
    final offer = serviceOffer();
    final repo = ScriptedOffersRepository(
      listResult: Right([offer]),
      detailResult: Right(offer),
    );
    await pumpOffersSurface(
      tester,
      child: OfferDetailView(offer: offer),
      cubit: OffersCubit(offersRepository: repo),
      onGenerateRoute: recorder,
    );
  }

  Future<void> tapPrimaryAction(WidgetTester tester) async {
    final action = find.byKey(const ValueKey('offer-primary-action'));
    await tester.ensureVisible(action);
    await tester.pump();
    await tester.tap(action);
  }

  testWidgets(
      'a GUEST tapping a SERVICE offer is prompted to sign in and never '
      'enters the booking flow', (tester) async {
    // AQG-439. Entering booking as a guest fires an authenticated address
    // read, whose 401 tears the session down mid-request and strands the
    // global loading overlay on the login page.
    await pumpDetail(tester);

    await tapPrimaryAction(tester);
    await settleOffers(tester);

    expect(pushed.where((r) => r.name == Routes.bookingLocation), isEmpty);
    expect(servicesRepo.calls, 0);
    expect(find.text('Please log in to access this feature'), findsOneWidget);
  });

  testWidgets('a SIGNED-IN customer still reaches the booking flow',
      (tester) async {
    signIn();
    await pumpDetail(tester);

    await tapPrimaryAction(tester);
    await settleOffers(tester);

    expect(servicesRepo.calls, 1);
  });
}
