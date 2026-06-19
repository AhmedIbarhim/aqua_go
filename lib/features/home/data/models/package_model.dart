import 'add_on_model.dart';
import '../../../../core/config/local_storage/shared_prefs.dart';
import '../../../../core/constants.dart';

class PackageModel {
  final String id;
  final String referenceNumber;
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
  final String createdAt;
  final String updatedAt;
  final int version;
  final String imageUrl;
  final bool isPopular;
  final int carsPerWash;
  final String effectiveFromAt;
  final String iconUrl;
  final List<AddOnModel> addons;

  PackageModel({
    required this.id,
    this.referenceNumber = '',
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
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.imageUrl,
    required this.isPopular,
    required this.carsPerWash,
    required this.effectiveFromAt,
    this.iconUrl = '',
    required this.addons,
  });

  // Dynamic getters for full backward compatibility
  String get title {
    final isArabic =
        CacheClient.getString(kLanguage, defaultValue: kArabicLang) ==
        kArabicLang;
    return isArabic ? nameAr : nameEn;
  }

  String get description {
    final isArabic =
        CacheClient.getString(kLanguage, defaultValue: kArabicLang) ==
        kArabicLang;
    return isArabic ? descriptionAr : descriptionEn;
  }

  String get price => (priceMinor / 100).toStringAsFixed(2);

  String get duration {
    final isArabic =
        CacheClient.getString(kLanguage, defaultValue: kArabicLang) ==
        kArabicLang;
    return isArabic ? '$validityDays يوم' : '$validityDays Days';
  }

  String get total => (num.parse(price) + num.parse(vat)).toStringAsFixed(2);
  String get vat => "0.0";
  // (num.parse(price) * .14).toStringAsFixed(2);

  List<AddOnModel> get includedAddons =>
      addons.where((e) => e.kind == 'INCLUDED').toList();

  List<AddOnModel> get optionalAddons =>
      addons.where((e) => e.kind == 'OPTIONAL').toList();

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    List<AddOnModel> parsedAddons =
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
    }

    if (json['optionalAddons'] != null) {
      parsedOptional = (json['optionalAddons'] as List<dynamic>)
          .map((e) => AddOnModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['availableOptionalAddons'] != null) {
      parsedOptional = (json['availableOptionalAddons'] as List<dynamic>)
          .map((e) => AddOnModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (parsedAddons.isEmpty) {
      for (final addon in parsedIncluded) {
        addon.kind ??= 'INCLUDED';
      }
      for (final addon in parsedOptional) {
        addon.kind ??= 'OPTIONAL';
      }
      parsedAddons = [...parsedIncluded, ...parsedOptional];
    }

    return PackageModel(
      id: json['id'] as String? ?? '',
      referenceNumber: json['referenceNumber'] as String? ?? '',
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
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      isPopular: json['isPopular'] as bool? ?? false,
      carsPerWash: (json['carsPerWash'] as num?)?.toInt() ?? 0,
      effectiveFromAt: json['effectiveFromAt'] as String? ?? '',
      iconUrl: json['iconUrl'] as String? ?? '',
      addons: parsedAddons,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referenceNumber': referenceNumber,
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
      'iconUrl': iconUrl,
      'addons': addons.map((e) => e.toJson()).toList(),
    };
  }
}
