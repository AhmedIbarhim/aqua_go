// Regression for the map picker's dead spinner: a device that never gets a
// location fix (indoors, GPS off, airplane mode, or the iOS Simulator's
// "Location > None") must not leave `determinePosition()` awaiting forever
// with `isLoading` stuck true and no way off the screen.
import 'dart:async';

import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/address/data/repos/maps_repository.dart';
import 'package:aqua_go/features/address/data/services/location_service.dart';
import 'package:aqua_go/features/address/presentation/controllers/maps_controller/maps_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Never exercised by the timeout path under test — [MapsRepository] just
/// needs a constructible [APIClient].
class _UnusedApiClient implements APIClient {
  @override
  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? parser,
  }) {
    throw StateError('not expected to be called by this test');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

/// Stands in for the platform channel. Grants permission and reports the
/// service enabled, then times out the fix itself — mirroring what the real
/// plugin does once `LocationSettings.timeLimit` elapses without a fix, so
/// the test doesn't have to wait out a real timeout.
class _TimingOutGeolocatorPlatform extends GeolocatorPlatform {
  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) {
    return Future<Position>.error(
      TimeoutException('fake platform never gets a fix'),
    );
  }

  @override
  Stream<ServiceStatus> getServiceStatusStream() => const Stream.empty();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheClient.init();
    GeolocatorPlatform.instance = _TimingOutGeolocatorPlatform();
  });

  group('MapsCubit.determinePosition', () {
    test(
      'a timing-out position fix clears isLoading instead of hanging forever',
      () async {
        final cubit = MapsCubit(
          mapsRepository: MapsRepository(
            locationService: LocationService(apiClient: _UnusedApiClient()),
          ),
        );
        addTearDown(cubit.close);

        await cubit.determinePosition();

        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.errorMessage, isNotNull);
      },
    );
  });
}
