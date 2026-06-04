import '../../../../core/config/local_storage/shared_prefs.dart';
import '../../../../core/constants.dart';
import 'package_addon_model.dart';

class PackageModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final int numWashes;
  final int validityDays;
  final int priceMinor;
  final String currency;
  final int maxActivePerCustomer;
  final bool allowScheduleLater;
  final bool active;
  final List<String> bundledServiceIds;
  final List<PackageAddonModel> includedAddons;
  final List<PackageAddonModel> optionalAddons;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String imageUrl;
  final bool isPopular;
  final int carsPerWash;
  final String effectiveFromAt;

  PackageModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.numWashes,
    required this.validityDays,
    required this.priceMinor,
    required this.currency,
    required this.maxActivePerCustomer,
    required this.allowScheduleLater,
    required this.active,
    required this.bundledServiceIds,
    required this.includedAddons,
    required this.optionalAddons,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.imageUrl,
    required this.isPopular,
    required this.carsPerWash,
    required this.effectiveFromAt,
  });

  // Dynamic getters for full backward compatibility
  String get title {
    final lang = CacheClient.getString(kLanguage);
    return lang == 'en' ? nameEn : nameAr;
  }

  String get description {
    final lang = CacheClient.getString(kLanguage);
    return lang == 'en' ? descriptionEn : descriptionAr;
  }

  String get price => (priceMinor / 100).toStringAsFixed(2);

  String get duration {
    final lang = CacheClient.getString(kLanguage);
    return lang == 'en' ? '$validityDays Days' : '$validityDays يوم';
  }

  String get image =>
      imageUrl.isNotEmpty ? imageUrl : 'assets/images/gift_demo.png';

  String get total => (num.parse(price) + num.parse(vat)).toStringAsFixed(2);
  String get vat => "0.0";
  // (num.parse(price) * .14).toStringAsFixed(2);

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      descriptionAr: json['descriptionAr'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      numWashes: (json['numWashes'] as num?)?.toInt() ?? 0,
      validityDays: (json['validityDays'] as num?)?.toInt() ?? 0,
      priceMinor: (json['priceMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? '',
      maxActivePerCustomer:
          (json['maxActivePerCustomer'] as num?)?.toInt() ?? 0,
      allowScheduleLater: json['allowScheduleLater'] as bool? ?? true,
      active: json['active'] as bool? ?? true,
      bundledServiceIds:
          (json['bundledServiceIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      includedAddons:
          (json['includedAddons'] as List<dynamic>?)
              ?.map(
                (e) => PackageAddonModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      optionalAddons:
          (json['optionalAddons'] as List<dynamic>?)
              ?.map(
                (e) => PackageAddonModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      isPopular: json['isPopular'] as bool? ?? false,
      carsPerWash: (json['carsPerWash'] as num?)?.toInt() ?? 0,
      effectiveFromAt: json['effectiveFromAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'numWashes': numWashes,
      'validityDays': validityDays,
      'priceMinor': priceMinor,
      'currency': currency,
      'maxActivePerCustomer': maxActivePerCustomer,
      'allowScheduleLater': allowScheduleLater,
      'active': active,
      'bundledServiceIds': bundledServiceIds,
      'includedAddons': includedAddons.map((e) => e.toJson()).toList(),
      'optionalAddons': optionalAddons.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'version': version,
      'imageUrl': imageUrl,
      'isPopular': isPopular,
      'carsPerWash': carsPerWash,
      'effectiveFromAt': effectiveFromAt,
    };
  }
}
