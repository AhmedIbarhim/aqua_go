import 'package:equatable/equatable.dart';

import '../../../../core/config/local_storage/shared_prefs.dart';
import '../../../../core/constants.dart';

class VehicleMakeModel extends Equatable {
  final String id;
  final MakeName vehicleMakeName;
  final bool active;
  final int version;
  final String logoUrl;
  final bool colorEditable;

  const VehicleMakeModel({
    required this.id,
    required this.vehicleMakeName,
    required this.active,
    required this.version,
    this.logoUrl = '',
    this.colorEditable = false,
  });

  factory VehicleMakeModel.fromJson(Map<String, dynamic> json) {
    return VehicleMakeModel(
      id: json['id'] as String,
      vehicleMakeName: MakeName.fromJson(json['name']),
      active: json['active'] as bool? ?? true,
      version: json['version'] as int? ?? 1,
      logoUrl: json['logoUrl'] as String? ?? '',
      colorEditable: json['colorEditable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': vehicleMakeName.toJson(),
      'active': active,
      'version': version,
      'logoUrl': logoUrl,
      'colorEditable': colorEditable,
    };
  }

  VehicleMakeModel copyWith({
    String? id,
    MakeName? vehicleMakeName,
    bool? active,
    int? version,
    String? logoUrl,
    bool? colorEditable,
  }) {
    return VehicleMakeModel(
      id: id ?? this.id,
      vehicleMakeName: vehicleMakeName ?? this.vehicleMakeName,
      active: active ?? this.active,
      version: version ?? this.version,
      logoUrl: logoUrl ?? this.logoUrl,
      colorEditable: colorEditable ?? this.colorEditable,
    );
  }

  @override
  List<Object?> get props => [id, vehicleMakeName, active, version, logoUrl, colorEditable];
}

class MakeName extends Equatable {
  final String nameAr;
  final String nameEn;

  const MakeName({required this.nameAr, required this.nameEn});

  factory MakeName.fromJson(dynamic json) {
    return MakeName(
      nameAr: json['ar']?.toString() ?? '',
      nameEn: json['en']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'ar': nameAr, 'en': nameEn};
  }

  String get localizedName {
    final isArabic = CacheClient.getString(kLanguage, defaultValue: kArabicLang) == kArabicLang;
    return isArabic ? nameAr : nameEn;
  }

  @override
  List<Object?> get props => [nameAr, nameEn];
}
