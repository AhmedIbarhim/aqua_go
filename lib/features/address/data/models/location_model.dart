/// PH1-005: mirrors the backend flat geo DTOs (`PlaceDetailsResponse` /
/// `ReverseGeocodeResponse`): {placeId, formattedAddress, latitude, longitude}.
class LocationModel {
  final String formattedAddress;
  final double lat;
  final double lng;

  LocationModel({
    required this.formattedAddress,
    required this.lat,
    required this.lng,
  });

  /// Parses the flat proxy DTO shared by place-details and reverse-geocode.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      formattedAddress: json['formattedAddress'] ?? '',
      lat: (json['latitude'] as num).toDouble(),
      lng: (json['longitude'] as num).toDouble(),
    );
  }
}
