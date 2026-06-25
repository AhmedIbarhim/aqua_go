import 'package:aqua_go/features/home/data/models/add_on_model.dart';
import 'package:aqua_go/features/home/data/models/service_model.dart';

class PackageInfo {
  final String nameAr;
  final String nameEn;
  final int numWashes;
  final int validityDays;
  final bool isPopular;
  final int carsPerWash;
  final List<String> bundledServiceIds;
  // Catalog-resolved bundled services (id + bilingual name + active), preserving
  // the order of [bundledServiceIds]. Resolved server-side so the service picker
  // can render every bundled service — INCLUDING inactive ones — without joining
  // against the active-only /services feed (which dropped inactive ids and forced
  // the picker into a load-failed state).
  final List<ServiceModel> bundledServices;
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
    this.bundledServices = const [],
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
      // Catalog-resolved bundled services. Each entry is {id, nameAr, nameEn,
      // active}; an id the catalog can no longer resolve still arrives with null
      // names + active=false so it stays selectable. Map to ServiceModel so the
      // existing picker (name-only) renders it directly.
      bundledServices:
          (json['bundledServices'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(
                (e) => ServiceModel(
                  id: e['id']?.toString() ?? '',
                  rawName: ServiceName(
                    nameAr: e['nameAr']?.toString() ?? '',
                    nameEn: e['nameEn']?.toString() ?? '',
                  ),
                  active: e['active'] as bool? ?? false,
                ),
              )
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
      'bundledServices': bundledServices
          .map(
            (s) => {
              'id': s.id,
              'nameAr': s.rawName?.nameAr ?? '',
              'nameEn': s.rawName?.nameEn ?? '',
              'active': s.active ?? false,
            },
          )
          .toList(),
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
