import 'location_model.dart';

class AddressModel {
  final String? id;
  final String label;
  final String details;
  final double lat;
  final double lng;
  final String? arrivalNotes;
  final String? zoneId;

  AddressModel({
    required this.id,
    required this.label,
    required this.details,
    required this.lat,
    required this.lng,
    this.arrivalNotes,
    this.zoneId,
  });

  AddressModel copyWith({
    String? id,
    String? label,
    String? details,
    double? lat,
    double? lng,
    String? arrivalNotes,
    String? zoneId,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      details: details ?? this.details,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      arrivalNotes: arrivalNotes ?? this.arrivalNotes,
      zoneId: zoneId ?? this.zoneId,
    );
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      label: json['label'] ?? '',
      details: json['details'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      arrivalNotes: json['arrivalNotes'],
      zoneId: json['zoneId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'label': label,
      'details': details,
      'lat': lat,
      'lng': lng,
      if (arrivalNotes != null) 'arrivalNotes': arrivalNotes,
      if (zoneId != null) 'zoneId': zoneId,
    };
  }

  factory AddressModel.fromLocation(
    LocationModel location, {
    required String name,
    String? id,
    String? zoneId,
  }) {
    return AddressModel(
      id: id,
      label: name,
      details: location.formattedAddress,
      lat: location.lat,
      lng: location.lng,
      zoneId: zoneId,
    );
  }
}
