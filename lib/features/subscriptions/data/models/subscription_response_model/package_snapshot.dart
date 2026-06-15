import 'package:aqua_go/features/home/data/models/add_on_model.dart';

class PackageInfo {
  final String nameAr;
  final String nameEn;
  final int numWashes;
  final int validityDays;
  final bool isPopular;
  final int carsPerWash;
  final List<String> bundledServiceIds;
  final List<AddOnModel> addons; // all addons, split by kind below
  final List<AddOnModel> includedAddons;
  final List<AddOnModel> optionalAddons;
  final String? imageUrl;
  final String? iconUrl;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? referenceNumber;

  PackageInfo({
    required this.nameAr,
    required this.nameEn,
    required this.numWashes,
    required this.validityDays,
    required this.isPopular,
    required this.carsPerWash,
    required this.bundledServiceIds,
    this.addons = const [],
    this.includedAddons = const [],
    this.optionalAddons = const [],
    this.imageUrl,
    this.iconUrl,
    this.descriptionAr,
    this.descriptionEn,
    this.referenceNumber,
  });

  factory PackageInfo.fromJson(Map<String, dynamic> json) {
    // Parse the single addons array — all items live here, distinguished by kind.
    final List<AddOnModel> parsedAddons =
        (json['addons'] as List<dynamic>?)
            ?.map((e) => AddOnModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Split by kind. The API uses uppercase 'INCLUDED' / 'OPTIONAL'.
    final included = parsedAddons
        .where((e) => e.kind?.toUpperCase() == 'INCLUDED')
        .toList();
    final optional = parsedAddons
        .where((e) => e.kind?.toUpperCase() == 'OPTIONAL')
        .toList();

    return PackageInfo(
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      numWashes: (json['numWashes'] as num?)?.toInt() ?? 0,
      validityDays: (json['validityDays'] as num?)?.toInt() ?? 0,
      isPopular: json['isPopular'] as bool? ?? false,
      carsPerWash: (json['carsPerWash'] as num?)?.toInt() ?? 0,
      bundledServiceIds:
          (json['bundledServiceIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      addons: parsedAddons,
      includedAddons: included,
      optionalAddons: optional,
      imageUrl: json['imageUrl'] as String?,
      iconUrl: json['iconUrl'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
      'numWashes': numWashes,
      'validityDays': validityDays,
      'isPopular': isPopular,
      'carsPerWash': carsPerWash,
      'bundledServiceIds': bundledServiceIds,
      'addons': addons.map((e) => e.toJson()).toList(),
      'includedAddons': includedAddons.map((e) => e.toJson()).toList(),
      'optionalAddons': optionalAddons.map((e) => e.toJson()).toList(),
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (iconUrl != null) 'iconUrl': iconUrl,
      if (descriptionAr != null) 'descriptionAr': descriptionAr,
      if (descriptionEn != null) 'descriptionEn': descriptionEn,
      if (referenceNumber != null) 'referenceNumber': referenceNumber,
    };
  }
}

typedef PackageSnapshot = PackageInfo;
