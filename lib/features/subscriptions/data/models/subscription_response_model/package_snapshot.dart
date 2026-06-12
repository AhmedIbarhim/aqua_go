import 'package:aqua_go/features/home/data/models/add_on_model.dart';

class PackageInfo {
  final String nameAr;
  final String nameEn;
  final int numWashes;
  final int validityDays;
  final bool allowScheduleLater;
  final List<String> bundledServiceIds;
  final List<AddOnModel> includedAddons;
  final List<AddOnModel> optionalAddons;
  final bool isPopular;
  final int carsPerWash;
  final List<AddOnModel> addons;

  PackageInfo({
    required this.nameAr,
    required this.nameEn,
    required this.numWashes,
    required this.validityDays,
    required this.allowScheduleLater,
    required this.bundledServiceIds,
    required this.includedAddons,
    required this.optionalAddons,
    required this.isPopular,
    required this.carsPerWash,
    this.addons = const [],
  });

  factory PackageInfo.fromJson(Map<String, dynamic> json) {
    final List<AddOnModel> parsedAddons =
        (json['addons'] as List<dynamic>?)
            ?.map((e) => AddOnModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    List<AddOnModel> parsedIncluded = [];
    List<AddOnModel> parsedOptional = [];
    if (json['includedAddons'] != null) {
      parsedIncluded = (json['includedAddons'] as List<dynamic>)
          .map((e) => AddOnModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['addOns'] != null) {
      parsedIncluded = (json['addOns'] as List<dynamic>)
          .map((e) => AddOnModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      parsedIncluded = parsedAddons.where((e) => e.kind == 'INCLUDED').toList();
    }

    if (json['optionalAddons'] != null) {
      parsedOptional = (json['optionalAddons'] as List<dynamic>)
          .map((e) => AddOnModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['availableOptionalAddons'] != null) {
      parsedOptional = (json['availableOptionalAddons'] as List<dynamic>)
          .map((e) => AddOnModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      parsedOptional = parsedAddons.where((e) => e.kind == 'OPTIONAL').toList();
    }

    return PackageInfo(
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      numWashes: (json['numWashes'] as num?)?.toInt() ?? 0,
      validityDays: (json['validityDays'] as num?)?.toInt() ?? 0,
      allowScheduleLater: json['allowScheduleLater'] as bool? ?? true,
      bundledServiceIds:
          (json['bundledServiceIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      includedAddons: parsedIncluded,
      optionalAddons: parsedOptional,
      isPopular: json['isPopular'] as bool? ?? false,
      carsPerWash: (json['carsPerWash'] as num?)?.toInt() ?? 0,
      addons: parsedAddons,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
      'numWashes': numWashes,
      'validityDays': validityDays,
      'allowScheduleLater': allowScheduleLater,
      'bundledServiceIds': bundledServiceIds,
      'includedAddons': includedAddons.map((e) => e.toJson()).toList(),
      'optionalAddons': optionalAddons.map((e) => e.toJson()).toList(),
      'isPopular': isPopular,
      'carsPerWash': carsPerWash,
      'addons': addons.map((e) => e.toJson()).toList(),
    };
  }
}

typedef PackageSnapshot = PackageInfo;
