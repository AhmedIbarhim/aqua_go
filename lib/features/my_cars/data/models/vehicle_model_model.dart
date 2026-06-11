import 'package:equatable/equatable.dart';

import '../../../../core/config/local_storage/shared_prefs.dart';
import '../../../../core/constants.dart';

class VehicleModelModel extends Equatable {
  final String id;
  final String makeId;
  final ModelName vehicleModelName;
  final bool active;
  final int version;

  const VehicleModelModel({
    required this.id,
    required this.makeId,
    required this.vehicleModelName,
    required this.active,
    required this.version,
  });

  factory VehicleModelModel.fromJson(Map<String, dynamic> json) {
    return VehicleModelModel(
      id: json['id'] as String,
      makeId: json['makeId'] as String,
      vehicleModelName: ModelName.fromJson(json['name']),
      active: json['active'] as bool? ?? true,
      version: json['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'makeId': makeId,
      'name': vehicleModelName.toJson(),
      'active': active,
      'version': version,
    };
  }

  @override
  List<Object?> get props => [id, makeId, vehicleModelName, active, version];
}

class ModelName extends Equatable {
  final String nameAr;
  final String nameEn;

  const ModelName({required this.nameAr, required this.nameEn});

  factory ModelName.fromJson(Map<String, dynamic> json) {
    return ModelName(
      nameAr: json['ar_SA'] as String? ?? '',
      nameEn: json['en'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'ar_SA': nameAr, 'en': nameEn};
  }

  String get localizedName {
    final isArabic = CacheClient.getString(kLanguage, defaultValue: kArabicLang) == kArabicLang;
    return isArabic ? nameAr : nameEn;
  }

  @override
  List<Object?> get props => [nameAr, nameEn];
}
