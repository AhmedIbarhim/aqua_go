import 'location_model.dart';

class AddressModel {
  final String id;
  final String name;
  final String formattedAddress;
  final double lat;
  final double lng;

  AddressModel({
    required this.id,
    required this.name,
    required this.formattedAddress,
    required this.lat,
    required this.lng,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'formatted_address': formattedAddress,
      'lat': lat,
      'lng': lng,
    };
  }

  factory AddressModel.fromLocation(
    LocationModel location, {
    required String name,
    String? id,
  }) {
    return AddressModel(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      formattedAddress: location.formattedAddress,
      lat: location.lat,
      lng: location.lng,
    );
  }
}
