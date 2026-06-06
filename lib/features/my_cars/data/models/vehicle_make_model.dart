import 'package:equatable/equatable.dart';

class VehicleMakeModel extends Equatable {
  final String id;
  final MakeName vehicleMakeName;
  final bool active;
  final int version;
  final String logoUrl;

  const VehicleMakeModel({
    required this.id,
    required this.vehicleMakeName,
    required this.active,
    required this.version,
    this.logoUrl = '',
  });

  factory VehicleMakeModel.fromJson(Map<String, dynamic> json) {
    return VehicleMakeModel(
      id: json['id'] as String,
      vehicleMakeName: MakeName.fromJson(json['name']),
      active: json['active'] as bool? ?? true,
      version: json['version'] as int? ?? 1,
      logoUrl: json['logoUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': vehicleMakeName.toJson(),
      'active': active,
      'version': version,
      'logoUrl': logoUrl,
    };
  }

  @override
  List<Object?> get props => [id, vehicleMakeName, active, version, logoUrl];
}

class MakeName extends Equatable {
  final String nameAr;
  final String nameEn;

  const MakeName({required this.nameAr, required this.nameEn});

  factory MakeName.fromJson(dynamic json) {
    return MakeName(
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
