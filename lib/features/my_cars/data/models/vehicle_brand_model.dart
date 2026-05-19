import 'package:equatable/equatable.dart';

class VehicleBrandModel extends Equatable {
  final String id;
  final BrandName vehicleBrandName;
  final bool active;
  final int version;

  const VehicleBrandModel({
    required this.id,
    required this.vehicleBrandName,
    required this.active,
    required this.version,
  });

  factory VehicleBrandModel.fromJson(Map<String, dynamic> json) {
    return VehicleBrandModel(
      id: json['id'] as String,
      vehicleBrandName: BrandName.fromJson(json['name']),
      active: json['active'] as bool? ?? true,
      version: json['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': vehicleBrandName.toJson(),
      'active': active,
      'version': version,
    };
  }

  @override
  List<Object?> get props => [id, vehicleBrandName, active, version];
}

class BrandName extends Equatable {
  final String nameAr;
  final String nameEn;

  const BrandName({required this.nameAr, required this.nameEn});

  factory BrandName.fromJson(dynamic json) {
    return BrandName(
      nameAr: json['ar_SA']?.toString() ?? '',
      nameEn: json['en']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'ar_SA': nameAr, 'en': nameEn};
  }

  @override
  List<Object?> get props => [nameAr, nameEn];
}
