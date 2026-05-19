import 'location_model.dart';

class AddressModel {
  final String? id;
  final String label;
  final String details;
  final double lat;
  final double lng;

  AddressModel({
    required this.id,
    required this.label,
    required this.details,
    required this.lat,
    required this.lng,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      label: json['label'] ?? '',
      details: json['details'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'label': label,
      'details': details,
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
      id: id,
      label: name,
      details: location.formattedAddress,
      lat: location.lat,
      lng: location.lng,
    );
  }
}
