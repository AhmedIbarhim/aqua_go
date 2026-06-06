import 'package:aqua_go/core/constants.dart';

import '../../../../core/config/local_storage/shared_prefs.dart';
import '../../../../core/helpers/car_color_helper.dart';
import 'vehicle_make_model.dart';
import 'vehicle_model_model.dart';

class MyCarModel {
  final String id;
  final String makeId;
  final String modelId;
  final String color;
  final int modelYear;
  final String logoUrl;
  final String plateNumber;
  final DateTime? createdAt;
  final VehicleMakeModel? carMake;
  final VehicleModelModel? carModel;

  MyCarModel({
    required this.id,
    required this.makeId,
    required this.modelId,
    required this.color,
    required this.modelYear,
    required this.logoUrl,
    required this.plateNumber,
    this.createdAt,
    this.carMake,
    this.carModel,
  });

  // Getter for make name
  String get make {
    if (carMake == null) return '';
    final isArabic = CacheClient.getString(kLanguage) == kArabicLang;
    return isArabic
        ? carMake!.vehicleMakeName.nameAr
        : carMake!.vehicleMakeName.nameEn;
  }

  // Getter for model name
  String get model {
    if (carModel == null) return '';
    final isArabic = CacheClient.getString(kLanguage) == kArabicLang;
    return isArabic
        ? carModel!.vehicleModelName.nameAr
        : carModel!.vehicleModelName.nameEn;
  }

  // Getter for year (API does not have year; return default placeholder or fallback)
  // String get modelYear => '2024';

  // Board number maps to plate number

  // Color code integer getter parsed from hex string color (e.g. "0xFFFFFF" or "#FFFFFF")
  int get colorCode {
    if (color.isEmpty) return 0xFFFFFFFF;
    try {
      String cleanColor = color
          .replaceAll('#', '')
          .replaceAll('0x', '')
          .replaceAll('0X', '');
      if (cleanColor.length == 6) {
        cleanColor = 'FF$cleanColor';
      }
      return int.parse(cleanColor, radix: 16);
    } catch (_) {
      return 0xFFFFFFFF;
    }
  }

  String get colorName => getLocalizedColorName(colorCode);

  factory MyCarModel.fromJson(
    Map<String, dynamic> json, {
    VehicleMakeModel? make,
    VehicleModelModel? modelRelation,
  }) {
    return MyCarModel(
      id: json['id'] as String,
      makeId: json['makeId'] as String,
      modelId: json['modelId'] as String,
      color: json['color'] as String? ?? '0xFFFFFFFF',
      modelYear: json['modelYear'] != null
          ? (json['modelYear'] is int
                ? json['modelYear'] as int
                : int.tryParse(json['modelYear'].toString()) ?? 2024)
          : 2024,
      plateNumber: json['plateNumber'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      logoUrl: json['logoUrl'] as String? ?? make?.logoUrl ?? '',
      carMake: make,
      carModel: modelRelation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'makeId': makeId,
      'modelId': modelId,
      'color': color,
      'modelYear': modelYear,
      'plateNumber': plateNumber,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'makeId': makeId,
      'modelId': modelId,
      'color': color,
      'modelYear': modelYear,
      'plateNumber': plateNumber,
    };
  }

  MyCarModel copyWith({
    String? id,
    String? makeId,
    String? modelId,
    String? color,
    int? modelYear,
    String? plateNumber,
    DateTime? createdAt,
    VehicleMakeModel? make,
    VehicleModelModel? modelRelation,
    String? logoUrl,
  }) {
    return MyCarModel(
      id: id ?? this.id,
      makeId: makeId ?? this.makeId,
      modelId: modelId ?? this.modelId,
      color: color ?? this.color,
      modelYear: modelYear ?? this.modelYear,
      plateNumber: plateNumber ?? this.plateNumber,
      createdAt: createdAt ?? this.createdAt,
      carMake: make ?? carMake,
      carModel: modelRelation ?? carModel,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}
