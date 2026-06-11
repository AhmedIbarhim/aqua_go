import 'package:equatable/equatable.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';

class ServiceAddonModel extends Equatable {
  final String id;
  final String code;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final bool active;
  final int priceMinor;
  final String currency;

  const ServiceAddonModel({
    required this.id,
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.active,
    required this.priceMinor,
    required this.currency,
  });

  // Dynamic localization getters for the UI
  String get name {
    final isArabic = CacheClient.getString(kLanguage, defaultValue: kArabicLang) == kArabicLang;
    return isArabic ? nameAr : nameEn;
  }

  String get description {
    final isArabic = CacheClient.getString(kLanguage, defaultValue: kArabicLang) == kArabicLang;
    return isArabic ? descriptionAr : descriptionEn;
  }

  double get priceDouble => priceMinor / 100;

  String get price => priceDouble.toStringAsFixed(2);

  factory ServiceAddonModel.fromJson(Map<String, dynamic> json) {
    final nameMap = json['name'] as Map<String, dynamic>?;
    final descMap = json['description'] as Map<String, dynamic>?;

    return ServiceAddonModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      nameAr: nameMap != null
          ? (nameMap['nameAr'] as String? ?? '')
          : (json['nameAr'] as String? ?? ''),
      nameEn: nameMap != null
          ? (nameMap['nameEn'] as String? ?? '')
          : (json['nameEn'] as String? ?? ''),
      descriptionAr: descMap != null
          ? (descMap['descriptionAr'] as String? ?? '')
          : (json['descriptionAr'] as String? ?? ''),
      descriptionEn: descMap != null
          ? (descMap['descriptionEn'] as String? ?? '')
          : (json['descriptionEn'] as String? ?? ''),
      active: json['active'] as bool? ?? true,
      priceMinor: (json['priceMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': {'nameAr': nameAr, 'nameEn': nameEn},
      'description': {
        'descriptionAr': descriptionAr,
        'descriptionEn': descriptionEn,
      },
      'active': active,
      'priceMinor': priceMinor,
      'currency': currency,
    };
  }

  @override
  List<Object?> get props => [
    id,
    code,
    nameAr,
    nameEn,
    descriptionAr,
    descriptionEn,
    active,
    priceMinor,
    currency,
  ];
}
