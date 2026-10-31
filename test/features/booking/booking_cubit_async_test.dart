import 'dart:async';

import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/utils/saudi_wire_format.dart';
import 'package:aqua_go/features/address/data/models/address_model.dart';
import 'package:aqua_go/features/booking/data/data_sources/bookings_remote_data_source.dart';
import 'package:aqua_go/features/booking/data/models/availability_response_model.dart';
import 'package:aqua_go/features/booking/data/repos/booking_repository.dart';
import 'package:aqua_go/features/booking/domain/configs/booking_flow_config.dart';
import 'package:aqua_go/features/booking/presentation/controllers/booking_cubit.dart';
import 'package:aqua_go/features/booking/presentation/controllers/booking_state.dart';
import 'package:aqua_go/features/home/data/models/service_model.dart';
import 'package:aqua_go/features/home/data/repos/services_repository.dart';
import 'package:aqua_go/features/home/data/data_source/services_remote_data_source.dart';
import 'package:aqua_go/features/subscriptions/data/data_sources/subscriptions_remote_data_source.dart';
import 'package:aqua_go/features/subscriptions/data/models/subscription_response_model/subscription_response_model.dart';
import 'package:aqua_go/features/subscriptions/data/repos/subscriptions_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/promo_summary_harness.dart';

typedef _Availability = Either<Failure, AvailabilityResponse>;
typedef _Zone = Either<Failure, Map<String, dynamic>>;

/// Every call parks until the test answers it, so a test decides the order
/// responses land in.
class _GatedBookingRepo extends BookingRepository {
  _GatedBookingRepo()
    : super(
        bookingsRemoteDataSource: BookingsRemoteDataSource(APIClient(Dio())),
      );

  final availability = <String, Completer<_Availability>>{};
  final zones = <Completer<_Zone>>[];

  @override
  Future<_Availability> getAvailability({
    required String zoneId,
    required String date,
    required String packageId,
  }) => (availability[date] = Completer<_Availability>()).future;

  @override
  Future<_Zone> checkZoneAvailability(double lat, double lng) {
    final zone = Completer<_Zone>();
    zones.add(zone);
    return zone.future;
  }
}

class _QueuedSubscriptionsRepo extends SubscriptionsRepository {
  _QueuedSubscriptionsRepo(this.responses)
    : super(SubscriptionsRemoteDataSource(APIClient(Dio())));

  final List<SubscriptionResponseModel> responses;

  @override
  Future<Either<Failure, SubscriptionResponseModel>> fetchSubscriptionDetail({
    required String subscriptionId,
  }) async => right(responses.removeAt(0));
}

BookingCubit _buildCubit({
  BookingRepository? repo,
  SubscriptionsRepository? subscriptionsRepo,
  BookingFlowConfig flowConfig = BookingFlowConfig.normal,
}) {
  final apiClient = APIClient(Dio());
  return BookingCubit(
    bookingRepo: repo ?? _GatedBookingRepo(),
    subscriptionsRepo:
        subscriptionsRepo ??
        SubscriptionsRepository(SubscriptionsRemoteDataSource(apiClient)),
    servicesRepo: ServicesRepository(ServicesRemoteDataSource(apiClient)),
    flowConfig: flowConfig,
  );
}

AddressModel _address(String id, {String? zoneId}) => AddressModel(
  id: id,
  label: id,
  details: id,
  lat: 21.4,
  lng: 39.1,
  zoneId: zoneId,
);

AvailabilitySlot _slot(DateTime start) => AvailabilitySlot(
  start: start,
  end: start.add(const Duration(hours: 1)),
  available: true,
);

SubscriptionResponseModel _subscription(List<String> addonIds) =>
    SubscriptionResponseModel.fromJson({
      'packageId': 'pkg-1',
      'packageInfo': {
        'bundledServices': [
          {
            'id': 'svc-1',
            'nameAr': 'خدمة',
            'nameEn': 'Service',
            'active': true,
          },
        ],
        'addons': [
          for (final id in addonIds)
            {'id': id, 'kind': 'OPTIONAL', 'priceMinor': 500},
        ],
      },
      'washes': [
        {'washId': 'wash-1', 'canSchedule': true},
      ],
    });

void main() {
  final dateA = DateTime.utc(2026, 11, 1);
  final dateB = DateTime.utc(2026, 11, 2);

  test(
    'a slow answer for an earlier date never replaces the newer slots',
    () async {
      final repo = _GatedBookingRepo();
      final cubit = _buildCubit(repo: repo);
      addTearDown(cubit.close);

      cubit.initBooking(service, existingAddress: _address('a', zoneId: 'z'));
      cubit.updateDateTime(dateA, null);
      cubit.updateDateTime(dateB, null);
      await pumpEventQueue();

      repo.availability[toWireDate(dateB)]!.complete(
        right(AvailabilityResponse(slots: [_slot(dateB)])),
      );
      await pumpEventQueue();
      repo.availability[toWireDate(dateA)]!.complete(
        right(AvailabilityResponse(slots: [_slot(dateA)])),
      );
      await pumpEventQueue();

      expect(cubit.state.availabilitySlots.single.start, dateB);
      expect(cubit.state.isAvailabilityLoading, isFalse);
    },
  );

  test(
    'a zone lookup for an old address never undoes a newer choice',
    () async {
      final repo = _GatedBookingRepo();
      final cubit = _buildCubit(repo: repo);
      addTearDown(cubit.close);

      cubit.initBooking(service);
      cubit.selectAddress(_address('old'));
      cubit.selectAddress(_address('new', zoneId: 'zone-new'));

      repo.zones.single.complete(right({'zoneId': 'zone-old'}));
      await pumpEventQueue();

      expect(cubit.state.selectedAddress?.id, 'new');
      expect(cubit.state.selectedAddress?.zoneId, 'zone-new');
    },
  );

  test(
    'a response landing after the screen closed is dropped quietly',
    () async {
      final repo = _GatedBookingRepo();
      final cubit = _buildCubit(repo: repo);

      cubit.initBooking(service, existingAddress: _address('a', zoneId: 'z'));
      final pending = cubit.fetchAvailability(targetDate: dateA);
      await cubit.close();

      repo.availability[toWireDate(dateA)]!.complete(
        right(AvailabilityResponse(slots: const [])),
      );

      await expectLater(pending, completes);
    },
  );

  test('editing a field mid-request does not hide the loading state', () async {
    final repo = _GatedBookingRepo();
    final cubit = _buildCubit(repo: repo);
    addTearDown(cubit.close);

    final pending = cubit.checkZone(21.4, 39.1);
    cubit.updateSpecialNoteText('ring the bell');

    expect(cubit.state.status, BookingStatus.loading);

    repo.zones.single.complete(right({'inServiceArea': false}));
    await pending;
  });

  test('editing a field still clears a failure', () async {
    final repo = _GatedBookingRepo();
    final cubit = _buildCubit(repo: repo);
    addTearDown(cubit.close);

    final pending = cubit.checkZone(21.4, 39.1);
    repo.zones.single.complete(left(ServerFailure('zone down')));
    await pending;
    expect(cubit.state.status, BookingStatus.failure);

    cubit.updateSpecialNoteText('ring the bell');

    expect(cubit.state.status, BookingStatus.initial);
    expect(cubit.state.errorMessage, isNull);
  });

  test(
    'a package refresh keeps the add-ons chosen when their order moves',
    () async {
      final cubit = _buildCubit(
        subscriptionsRepo: _QueuedSubscriptionsRepo([
          _subscription(['first', 'second']),
          _subscription(['second', 'first']),
        ]),
        flowConfig: const BookingFlowConfig(flowType: BookingFlowType.package),
      );
      addTearDown(cubit.close);

      cubit.initBooking(ServiceModel(id: 'pkg-1'), subscriptionId: 'sub-1');
      await pumpEventQueue();
      cubit.toggleService(0);

      await cubit.refreshCatalog();

      final addons = cubit.state.selectedService!.addons;
      expect(cubit.state.selectedServiceIndices.map((i) => addons[i].id), [
        'first',
      ]);
    },
  );
}
