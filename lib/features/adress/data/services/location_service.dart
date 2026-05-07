import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:dio/dio.dart';

import '../../../../core/config/networking/endpoints.dart';

class LocationService {
  final APIClient apiClient;
  final String _apiKey = 'AIzaSyCBWbLd9irc4PCEchf4WEMdIY8Io-PnScc';

  LocationService({required this.apiClient});

  Future<Response> getAutocomplete(String query) async {
    return await apiClient.get(
      Endpoints.googleMapsAutocompleteUrl,
      queryParameters: {
        'input': query,
        'key': _apiKey,
        'language': 'ar',
        'components': 'country:sa',
      },
    );
  }

  Future<Response> getPlaceDetails(String placeId) async {
    return await apiClient.get(
      Endpoints.googleMapsPlaceDetailsUrl,
      queryParameters: {'place_id': placeId, 'key': _apiKey, 'language': 'ar'},
    );
  }

  Future<Response> getAddressFromLatLng(double lat, double lng) async {
    return await apiClient.get(
      Endpoints.googleMapsGeocodeUrl,
      queryParameters: {
        'latlng': '$lat,$lng',
        'key': _apiKey,
        'language': 'ar',
      },
    );
  }
}
