import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/config/local_storage/shared_prefs.dart';
import '../../../../core/config/networking/endpoints.dart';
import '../../../../core/constants.dart';

/// PH1-005: address lookups go through the backend `geo/places` proxy — the
/// Google Maps key lives on the server (R-19 adapter), never in the shipped app.
/// The shared [APIClient] attaches the customer JWT for these relative-path
/// calls. Responses are tech-neutral DTOs (NOT raw Google JSON).
class LocationService {
  final APIClient apiClient;

  LocationService({required this.apiClient});

  /// Backend language code derived from the persisted UI language.
  String get _lang =>
      CacheClient.getString(kLanguage, defaultValue: kArabicLang) == kArabicLang
          ? 'ar'
          : 'en';

  /// [sessionToken] groups the autocomplete calls of one search session for
  /// Google billing — mint one UUID per session, reuse until a result is picked.
  Future<Either<Failure, dynamic>> getAutocomplete(
    String query,
    String sessionToken,
  ) {
    return apiClient.get(
      Endpoints.geoPlacesAutocomplete,
      queryParameters: {
        'q': query,
        'lang': _lang,
        'sessionToken': sessionToken,
      },
    );
  }

  Future<Either<Failure, dynamic>> getPlaceDetails(String placeId) {
    return apiClient.get(
      Endpoints.geoPlaceDetail(placeId),
      queryParameters: {'lang': _lang},
    );
  }

  Future<Either<Failure, dynamic>> getAddressFromLatLng(
    double lat,
    double lng,
  ) {
    return apiClient.get(
      Endpoints.geoPlacesReverseGeocode,
      queryParameters: {'lat': lat, 'lng': lng, 'lang': _lang},
    );
  }
}
