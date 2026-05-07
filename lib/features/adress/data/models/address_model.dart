class AddressModel {
  final String formattedAddress;
  final double lat;
  final double lng;

  AddressModel({
    required this.formattedAddress,
    required this.lat,
    required this.lng,
  });

  factory AddressModel.fromGeocodeJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    return AddressModel(
      formattedAddress: json['formatted_address'] ?? '',
      lat: (location['lat'] as num).toDouble(),
      lng: (location['lng'] as num).toDouble(),
    );
  }

  factory AddressModel.fromPlaceDetailsJson(Map<String, dynamic> json) {
    final location = json['result']['geometry']['location'];
    return AddressModel(
      formattedAddress: json['result']['formatted_address'] ?? json['result']['name'] ?? '',
      lat: (location['lat'] as num).toDouble(),
      lng: (location['lng'] as num).toDouble(),
    );
  }
}
