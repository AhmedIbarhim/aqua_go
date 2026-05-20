import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/config/local_storage/shared_prefs.dart';
import '../../../../core/config/networking/endpoints.dart';
import '../../../../core/constants.dart';

class LocationService {
  final APIClient apiClient;
  final String _apiKey = 'AIzaSyCBWbLd9irc4PCEchf4WEMdIY8Io-PnScc';

  LocationService({required this.apiClient});

  Future<Either<Failure, dynamic>> getAutocomplete(String query) {
    return apiClient.get(
      Endpoints.googleMapsAutocompleteUrl,
      queryParameters: {
        'input': query,
        'key': _apiKey,
        'language': CacheClient.getString(kLanguage) == 'en' ? 'en' : 'ar',
        'components': 'country:sa',
      },
    );
  }

  Future<Either<Failure, dynamic>> getPlaceDetails(String placeId) {
    return apiClient.get(
      Endpoints.googleMapsPlaceDetailsUrl,
      queryParameters: {'place_id': placeId, 'key': _apiKey, 'language': 'ar'},
    );
  }

  Future<Either<Failure, dynamic>> getAddressFromLatLng(
    double lat,
    double lng,
  ) {
    return apiClient.get(
      Endpoints.googleMapsGeocodeUrl,
      queryParameters: {
        'latlng': '$lat,$lng',
        'key': _apiKey,
        'language': 'ar',
      },
    );
  }
}
