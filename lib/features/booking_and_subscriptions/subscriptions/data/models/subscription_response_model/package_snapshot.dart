import 'package:aqua_go/features/home/data/models/package_addon_model.dart';
import 'subscription_package_addon.dart';

class PackageSnapshot {
  final String nameAr;
  final String nameEn;
  final int numWashes;
  final int validityDays;
  final bool allowScheduleLater;
  final List<String> bundledServiceIds;
  final List<PackageAddonModel> includedAddons;
  final List<PackageAddonModel> optionalAddons;
  final bool isPopular;
  final int carsPerWash;
  final List<SubscriptionPackageAddon> addons;

  PackageSnapshot({
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

  factory PackageSnapshot.fromJson(Map<String, dynamic> json) {
    final List<SubscriptionPackageAddon> parsedAddons = (json['addons'] as List<dynamic>?)
            ?.map((e) => SubscriptionPackageAddon.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    List<PackageAddonModel> parsedIncluded = [];
    List<PackageAddonModel> parsedOptional = [];
    if (json['includedAddons'] != null) {
      parsedIncluded = (json['includedAddons'] as List<dynamic>)
          .map((e) => PackageAddonModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      parsedIncluded = parsedAddons
          .where((e) => e.kind == 'INCLUDED')
          .map((e) => PackageAddonModel(
                addonId: e.addonId,
                qty: e.freeQty ?? 1,
                deltaPriceMinor: e.unitPriceMinor ?? 0,
              ))
          .toList();
    }

    if (json['optionalAddons'] != null) {
      parsedOptional = (json['optionalAddons'] as List<dynamic>)
          .map((e) => PackageAddonModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      parsedOptional = parsedAddons
          .where((e) => e.kind == 'OPTIONAL')
          .map((e) => PackageAddonModel(
                addonId: e.addonId,
                qty: 1,
                deltaPriceMinor: e.unitPriceMinor ?? 0,
              ))
          .toList();
    }

    return PackageSnapshot(
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
