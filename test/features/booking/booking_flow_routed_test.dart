import 'dart:async';

import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/enums/payment_method_enum.dart';
import 'package:aqua_go/core/route/app_router.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/features/address/data/data_sources/addresses_remote_data_source.dart';
import 'package:aqua_go/features/address/data/models/address_model.dart';
import 'package:aqua_go/features/address/data/repos/addresses_repository.dart';
import 'package:aqua_go/features/address/presentation/controllers/addresses_controller/addresses_cubit.dart';
import 'package:aqua_go/features/address/presentation/controllers/maps_controller/maps_cubit.dart';
import 'package:aqua_go/features/booking/data/models/package_booking_request_model.dart';
import 'package:aqua_go/features/booking/data/models/service_reschedule_request_model.dart';
import 'package:aqua_go/features/booking/data/repos/booking_repository.dart';
import 'package:aqua_go/features/booking/domain/configs/booking_flow_config.dart';
import 'package:aqua_go/features/booking/domain/strategies/package_booking_submit.dart';
import 'package:aqua_go/features/booking/domain/strategies/redeem_gift_booking_submit.dart';
import 'package:aqua_go/features/booking/domain/strategies/service_reschedule_booking_submit.dart';
import 'package:aqua_go/features/booking/presentation/controllers/booking_cubit.dart';
import 'package:aqua_go/features/booking/presentation/controllers/booking_pricing_cubit.dart';
import 'package:aqua_go/features/booking/presentation/views/booking_details_view.dart';
import 'package:aqua_go/features/booking/presentation/views/booking_location_view.dart';
import 'package:aqua_go/features/booking/presentation/views/booking_summary_view.dart';
import 'package:aqua_go/features/home/data/data_source/services_remote_data_source.dart';
import 'package:aqua_go/features/home/data/models/service_model.dart';
import 'package:aqua_go/features/home/data/repos/services_repository.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/features/subscriptions/data/data_sources/subscriptions_remote_data_source.dart';
import 'package:aqua_go/features/subscriptions/data/models/subscription_response_model/subscription_response_model.dart';
import 'package:aqua_go/features/subscriptions/data/repos/subscriptions_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/promo_summary_harness.dart';

/// Walks each booking flow through the REAL [AppRouter] and real screens, tap by
/// tap. The other booking tests mount one screen on hand-built cubits, so only
/// this file covers what the routes wire up: cubit creation, the location
/// screen's overlay, and the hand-off between screens.
class _FlowRepo extends RecordingBookingRepo {
  _FlowRepo(String? Function() quoteError)
    : super(
        expiredQuotes: false,
        quoteFailure: (_, _) {
          final message = quoteError();
          return message == null ? null : ServerFailure(message);
        },
      );

  final List<String> submitted = [];

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkZoneAvailability(
    double lat,
    double lng,
  ) async => right({'inServiceArea': true, 'zoneId': 'zone-1'});

  Either<Failure, BookingResponseModel> _record(String call) {
    submitted.add(call);
    return left(ServerFailure('stop before the success navigation'));
  }

  @override
  Future<Either<Failure, BookingResponseModel>> redeemGiftBooking(
    Map<String, dynamic> data,
  ) async {
    await networkTick();
    return _record('gift:${data['giftCode']}');
  }

  @override
  Future<Either<Failure, BookingResponseModel>> rescheduleBooking(
    ServiceRescheduleRequestModel rescheduleRequest,
  ) async {
    await networkTick();
    return _record('reschedule:${rescheduleRequest.bookingId}');
  }

  @override
  Future<Either<Failure, BookingResponseModel>> scheduleSubscriptionWash({
    required String subscriptionId,
    required String washId,
    required PackageBookingRequestModel request,
  }) async {
    await networkTick();
    return _record('wash:$subscriptionId/$washId');
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  previewScheduleSubscriptionWash({
    required String subscriptionId,
    required String washId,
    required Map<String, dynamic> scheduleData,
  }) async {
    await networkTick();
    return right({'chargeTotalMinor': 0});
  }
}

class _StubMaps extends Cubit<MapsState> implements MapsCubit {
  _StubMaps() : super(const MapsState());

  @override
  Future<void> determinePosition() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoAddressesRepo extends AddressesRepository {
  _NoAddressesRepo() : super(AddressesRemoteDataSource(APIClient(Dio())));

  @override
  Future<Either<Failure, List<AddressModel>>> fetchAddresses() async =>
      right(const []);
}

class _NoServicesRepo extends ServicesRepository {
  _NoServicesRepo() : super(ServicesRemoteDataSource(APIClient(Dio())));

  @override
  Future<Either<Failure, List<ServiceModel>>> fetchServices() async =>
      right(const []);
}

class _SubscriptionRepo extends SubscriptionsRepository {
  _SubscriptionRepo() : super(SubscriptionsRemoteDataSource(APIClient(Dio())));

  @override
  Future<Either<Failure, SubscriptionResponseModel>> fetchSubscriptionDetail({
    required String subscriptionId,
  }) async {
    await networkTick();
    return right(
      SubscriptionResponseModel.fromJson({
        'packageId': 'pkg-1',
        'packageInfo': {
          'nameEn': 'Package',
          'bundledServices': [
            {'id': 'svc-1', 'nameAr': 'خدمة', 'nameEn': 'Svc', 'active': true},
          ],
        },
        'washes': [
          {'washId': 'wash-1', 'canSchedule': true},
        ],
      }),
    );
  }
}

void _register<T extends Object>(T Function() create) {
  if (locator.isRegistered<T>()) locator.unregister<T>();
  locator.registerFactory<T>(create);
}

void main() {
  late _FlowRepo repo;
  late GlobalKey<NavigatorState> navigator;
  String? quoteError;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await CacheClient.init();
    await EasyLocalization.ensureInitialized();
    await loadTranslations();
  });

  setUp(() {
    quoteError = null;
    repo = _FlowRepo(() => quoteError);
    navigator = GlobalKey<NavigatorState>();
    _register<BookingRepository>(() => repo);
    _register<SubscriptionsRepository>(_SubscriptionRepo.new);
    _register<ServicesRepository>(_NoServicesRepo.new);
    _register<AddressesCubit>(
      () => AddressesCubit(repository: _NoAddressesRepo()),
    );
    _register<MapsCubit>(_StubMaps.new);
    registerFlowScreenFakes();
  });

  Finder overlay() => find.byType(CustomLoadingIndicator);

  Future<void> tapBottomButton(WidgetTester tester) async {
    await tester.tap(find.byType(MaterialButton).last);
    await settle(tester);
  }

  Future<void> start(WidgetTester tester, BookingFlowStartArgs args) async {
    tester.view.physicalSize = const Size(1400, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(routedApp(navigator));
    await tester.pumpAndSettle();
    navigator.currentState!.pushNamed(Routes.bookingLocation, arguments: args);
    await settle(tester);
    expect(find.byType(BookingLocationView), findsOneWidget);

    await tapBottomButton(tester);
    expect(find.byType(BookingDetailsView), findsOneWidget);
    expect(overlay(), findsNothing);
  }

  void pickSlot(WidgetTester tester) {
    final booking = tester
        .element(find.byType(BookingDetailsView))
        .read<BookingCubit>();
    final date = DateTime.now().add(const Duration(days: 2));
    booking.updateDateTime(date, null);
    booking.updateDateTime(date, DateTime(date.year, date.month, date.day, 10));
  }

  testWidgets('service: location, details, summary, payment', (tester) async {
    await start(
      tester,
      BookingFlowStartArgs(
        service: service,
        existingCar: car,
        existingAddress: address,
      ),
    );
    expect(repo.quoteCalls, isNotEmpty, reason: 'details prices on open');

    pickSlot(tester);
    await settle(tester);
    final quotesBeforeSummary = repo.quoteCalls.length;
    await tester.tap(find.byType(MaterialButton).last);

    // The summary re-prices on open. Stop inside the request: the overlay must
    // be up, driven from the location screen two routes below.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
    expect(repo.quoteCalls.length, quotesBeforeSummary + 1);
    expect(overlay(), findsOneWidget);

    await settle(tester);
    expect(find.byType(BookingSummaryView), findsOneWidget);
    expect(overlay(), findsNothing);

    tester
        .element(find.byType(BookingSummaryView))
        .read<BookingCubit>()
        .updatePaymentMethod(PaymentMethod.creditCard);
    await settle(tester);

    await tapBottomButton(tester);

    expect(repo.paymentInitCalls, 1);
    expect(overlay(), findsNothing);
  });

  testWidgets('leaving details mid-quote does not strand the overlay', (
    tester,
  ) async {
    await start(
      tester,
      BookingFlowStartArgs(
        service: service,
        existingCar: car,
        existingAddress: address,
      ),
    );

    final pricing = tester
        .element(find.byType(BookingDetailsView))
        .read<BookingPricingCubit>();
    unawaited(pricing.repriceForDisplayWithoutPromo());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
    expect(overlay(), findsOneWidget);

    navigator.currentState!.pop();
    await settle(tester);

    expect(find.byType(BookingLocationView), findsOneWidget);
    expect(overlay(), findsNothing);
  });

  testWidgets('a quote failure is still reported under another screen', (
    tester,
  ) async {
    await start(
      tester,
      BookingFlowStartArgs(
        service: service,
        existingCar: car,
        existingAddress: address,
      ),
    );
    final pricing = tester
        .element(find.byType(BookingDetailsView))
        .read<BookingPricingCubit>();

    // What the add-car screen does to the debounced re-price: the customer has
    // moved on by the time the failure lands.
    quoteError = 'pricing is down';
    navigator.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Scaffold()),
    );
    await tester.pumpAndSettle();
    unawaited(pricing.repriceForDisplayWithoutPromo());
    await tester.pump(const Duration(milliseconds: 30));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('pricing is down'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('gift: redeems from the summary with the gift code', (
    tester,
  ) async {
    await start(
      tester,
      BookingFlowStartArgs(
        service: service,
        existingCar: car,
        existingAddress: address,
        giftCode: 'GIFT1',
        flowConfig: const BookingFlowConfig(
          flowType: BookingFlowType.giftRedeem,
        ),
        submitStrategy: const RedeemGiftBookingSubmit(),
      ),
    );

    pickSlot(tester);
    await settle(tester);
    await tapBottomButton(tester);
    expect(find.byType(BookingSummaryView), findsOneWidget);

    await tapBottomButton(tester);

    expect(repo.submitted, ['gift:GIFT1']);
    expect(repo.quoteCalls, isEmpty, reason: 'a gift is never quoted');
    expect(overlay(), findsNothing);
  });

  testWidgets('reschedule: submits from details, with no summary', (
    tester,
  ) async {
    await start(
      tester,
      BookingFlowStartArgs(
        service: service,
        existingCar: car,
        existingAddress: address,
        flowConfig: const BookingFlowConfig(
          flowType: BookingFlowType.reschedule,
        ),
        submitStrategy: ServiceRescheduleBookingSubmit(
          existingBookingId: 'b-1',
        ),
      ),
    );

    pickSlot(tester);
    await settle(tester);
    await tapBottomButton(tester);

    expect(repo.submitted, ['reschedule:b-1']);
    expect(find.byType(BookingDetailsView), findsOneWidget);
    expect(overlay(), findsNothing);
  });

  testWidgets('package: previews the charge, then schedules the wash', (
    tester,
  ) async {
    await start(
      tester,
      BookingFlowStartArgs(
        existingCar: car,
        existingAddress: address,
        subscriptionId: 'sub-1',
        flowConfig: const BookingFlowConfig(flowType: BookingFlowType.package),
        submitStrategy: const PackageBookingSubmit(),
      ),
    );

    pickSlot(tester);
    await settle(tester);
    await tapBottomButton(tester);
    expect(find.byType(BookingSummaryView), findsOneWidget);

    await tapBottomButton(tester);

    expect(repo.submitted, ['wash:sub-1/wash-1']);
    expect(overlay(), findsNothing);
  });
}
