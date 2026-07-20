// PH1-005: LocationService must route through the backend geo/places proxy —
// relative paths, a sessionToken, no embedded Google key, no googleapis host.
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/address/data/models/location_model.dart';
import 'package:aqua_go/features/address/data/models/place_prediction_model.dart';
import 'package:aqua_go/features/address/data/repos/maps_repository.dart';
import 'package:aqua_go/features/address/data/services/location_service.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records the last request and returns a canned response body.
class _FakeApiClient implements APIClient {
  _FakeApiClient(this.response);
  final dynamic response;
  String? lastPath;
  Map<String, dynamic>? lastQuery;

  @override
  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? parser,
  }) async {
    lastPath = path;
    lastQuery = queryParameters;
    return Right(response as T);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheClient.init();
  });

  group('LocationService proxy routing', () {
    test('getAutocomplete hits the proxy with sessionToken, no key/host',
        () async {
      final api = _FakeApiClient({'suggestions': []});
      final service = LocationService(apiClient: api);

      await service.getAutocomplete('jed', 'session-123');

      expect(api.lastPath, Endpoints.geoPlacesAutocomplete);
      expect(api.lastPath, isNot(contains('maps.googleapis.com')));
      expect(api.lastQuery!['sessionToken'], 'session-123');
      expect(api.lastQuery!.containsKey('key'), isFalse);
      expect(api.lastQuery!['q'], 'jed');
      expect(api.lastQuery!['lang'], anyOf('ar', 'en'));
    });

    test('getPlaceDetails hits the place-detail proxy path', () async {
      final api = _FakeApiClient({});
      final service = LocationService(apiClient: api);

      await service.getPlaceDetails('place-xyz');

      expect(api.lastPath, Endpoints.geoPlaceDetail('place-xyz'));
      expect(api.lastQuery!.containsKey('key'), isFalse);
    });

    test('getAddressFromLatLng hits reverse-geocode with lat/lng/lang',
        () async {
      final api = _FakeApiClient({});
      final service = LocationService(apiClient: api);

      await service.getAddressFromLatLng(21.5, 39.2);

      expect(api.lastPath, Endpoints.geoPlacesReverseGeocode);
      expect(api.lastQuery!['lat'], 21.5);
      expect(api.lastQuery!['lng'], 39.2);
      expect(api.lastQuery!.containsKey('lang'), isTrue);
      expect(api.lastQuery!.containsKey('key'), isFalse);
    });
  });

  group('MapsRepository DTO parsing', () {
    test('autocomplete maps {suggestions:[{placeId,mainText,secondaryText}]}',
        () async {
      final api = _FakeApiClient({
        'suggestions': [
          {
            'placeId': 'p1',
            'mainText': 'King Road',
            'secondaryText': 'Jeddah',
          },
        ],
      });
      final repo = MapsRepository(locationService: LocationService(apiClient: api));

      final result = await repo.getAutocomplete('king', 'session-1');

      final list = result.getOrElse(() => <PlacePredictionModel>[]);
      expect(list, hasLength(1));
      expect(list.first.placeId, 'p1');
      expect(list.first.mainText, 'King Road');
      expect(list.first.secondaryText, 'Jeddah');
      expect(list.first.description, 'King Road, Jeddah');
    });

    test('place-details maps flat {placeId,formattedAddress,lat,lng}', () async {
      final api = _FakeApiClient({
        'placeId': 'p1',
        'formattedAddress': 'King Road, Jeddah',
        'latitude': 21.5,
        'longitude': 39.2,
      });
      final repo = MapsRepository(locationService: LocationService(apiClient: api));

      final result = await repo.getPlaceDetails('p1');
      final model = result.getOrElse(
        () => LocationModel(formattedAddress: '', lat: 0, lng: 0),
      );
      expect(model.formattedAddress, 'King Road, Jeddah');
      expect(model.lat, 21.5);
      expect(model.lng, 39.2);
    });

    test('reverse-geocode maps the same flat shape', () async {
      final api = _FakeApiClient({
        'placeId': 'p2',
        'formattedAddress': 'Corniche, Jeddah',
        'latitude': 21.6,
        'longitude': 39.1,
      });
      final repo = MapsRepository(locationService: LocationService(apiClient: api));

      final result = await repo.getAddressFromLatLng(21.6, 39.1);
      final model = result.getOrElse(
        () => LocationModel(formattedAddress: '', lat: 0, lng: 0),
      );
      expect(model.formattedAddress, 'Corniche, Jeddah');
      expect(model.lat, 21.6);
    });
  });
}
