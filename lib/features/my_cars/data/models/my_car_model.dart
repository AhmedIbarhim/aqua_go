import '../../../../core/helpers/car_color_helper.dart';
import '../../../../core/utils/app_assets.dart';
import 'vehicle_brand_model.dart';
import 'vehicle_model_model.dart';

class MyCarModel {
  final String id;
  final String makeId;
  final String modelId;
  final String color;
  final String plateNumber;
  final DateTime? createdAt;
  final VehicleBrandModel? carBrand;
  final VehicleModelModel? carModel;

  MyCarModel({
    required this.id,
    required this.makeId,
    required this.modelId,
    required this.color,
    required this.plateNumber,
    this.createdAt,
    this.carBrand,
    this.carModel,
  });

  // // Getter for brand / make name
  // String get name {
  //   if (carBrand == null) return '';
  //   final isArabic = Intl.defaultLocale?.startsWith('ar') ?? false;
  //   return isArabic ? carBrand!.brandName.nameAr : carBrand!.brandName.nameEn;
  // }

  // // Getter for model name
  // String get model {
  //   if (carModel == null) return '';
  //   final isArabic = Intl.defaultLocale?.startsWith('ar') ?? false;
  //   return isArabic ? carModel!.name.nameAr : carModel!.name.nameEn;
  // }

  // Getter for year (API does not have year; return default placeholder or fallback)
  String get year => '2024';

  // Board number maps to plate number
  String get boardNumber => plateNumber;

  // Generic car asset
  String get image => AppAssets.myCar;

  // Make brand logo
  String get typeImage {
    return AppAssets.demoToyota;
  }

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
    VehicleBrandModel? make,
    VehicleModelModel? modelRelation,
  }) {
    return MyCarModel(
      id: json['id'] as String,
      makeId: json['makeId'] as String,
      modelId: json['modelId'] as String,
      color: json['color'] as String? ?? '0xFFFFFFFF',
      plateNumber: json['plateNumber'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      carBrand: make,
      carModel: modelRelation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'makeId': makeId,
      'modelId': modelId,
      'color': color,
      'plateNumber': plateNumber,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'makeId': makeId,
      'modelId': modelId,
      'color': color,
      'plateNumber': plateNumber,
    };
  }

  MyCarModel copyWith({
    String? id,
    String? makeId,
    String? modelId,
    String? color,
    String? plateNumber,
    DateTime? createdAt,
    VehicleBrandModel? make,
    VehicleModelModel? modelRelation,
  }) {
    return MyCarModel(
      id: id ?? this.id,
      makeId: makeId ?? this.makeId,
      modelId: modelId ?? this.modelId,
      color: color ?? this.color,
      plateNumber: plateNumber ?? this.plateNumber,
      createdAt: createdAt ?? this.createdAt,
      carBrand: make ?? carBrand,
      carModel: modelRelation ?? carModel,
    );
  }
}
