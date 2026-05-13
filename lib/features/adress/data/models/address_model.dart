import 'location_model.dart';

class AddressModel {
  final String name;
  final String formattedAddress;
  final double lat;
  final double lng;

  AddressModel({
    required this.name,
    required this.formattedAddress,
    required this.lat,
    required this.lng,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      name: json['name'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'formatted_address': formattedAddress,
      'lat': lat,
      'lng': lng,
    };
  }

  factory AddressModel.fromLocation(
    LocationModel location, {
    required String name,
  }) {
    return AddressModel(
      name: name,
      formattedAddress: location.formattedAddress,
      lat: location.lat,
      lng: location.lng,
    );
  }
}
