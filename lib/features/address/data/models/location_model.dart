class LocationModel {
  final String formattedAddress;
  final double lat;
  final double lng;

  LocationModel({
    required this.formattedAddress,
    required this.lat,
    required this.lng,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      formattedAddress: json['formattedAddress'] ?? '',
      lat: (json['latitude'] as num).toDouble(),
      lng: (json['longitude'] as num).toDouble(),
    );
  }
}
