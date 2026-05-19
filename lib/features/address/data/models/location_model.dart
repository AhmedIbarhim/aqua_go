class LocationModel {
  final String formattedAddress;
  final double lat;
  final double lng;

  LocationModel({
    required this.formattedAddress,
    required this.lat,
    required this.lng,
  });

  factory LocationModel.fromGeocodeJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    return LocationModel(
      formattedAddress: json['formatted_address'] ?? '',
      lat: (location['lat'] as num).toDouble(),
      lng: (location['lng'] as num).toDouble(),
    );
  }

  factory LocationModel.fromPlaceDetailsJson(Map<String, dynamic> json) {
    final location = json['result']['geometry']['location'];
    return LocationModel(
      formattedAddress:
          json['result']['formatted_address'] ?? json['result']['name'] ?? '',
      lat: (location['lat'] as num).toDouble(),
      lng: (location['lng'] as num).toDouble(),
    );
  }
}
