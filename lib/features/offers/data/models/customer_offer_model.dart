import '../../../../core/utils/saudi_wire_format.dart';

class OfferTermsModel {
  final String? promoCode;
  final String? discountType;
  final int configuredValue;
  final int minOrderMinor;
  final String? packageId;
  final String? packageNameAr;
  final String? packageNameEn;
  final int packagePriceMinor;
  final int packageNumWashes;
  final int packageValidityDays;

  final List<String> applicableServiceNamesAr;
  final List<String> applicableServiceNamesEn;
  final List<String> applicableZoneNamesAr;
  final List<String> applicableZoneNamesEn;

  final String? serviceId;
  final String? serviceNameAr;
  final String? serviceNameEn;

  final int serviceListPriceMinor;

  final int targetPriceMinor;

  const OfferTermsModel({
    this.promoCode,
    this.discountType,
    this.configuredValue = 0,
    this.minOrderMinor = 0,
    this.packageId,
    this.packageNameAr,
    this.packageNameEn,
    this.packagePriceMinor = 0,
    this.packageNumWashes = 0,
    this.packageValidityDays = 0,
    this.applicableServiceNamesAr = const [],
    this.applicableServiceNamesEn = const [],
    this.applicableZoneNamesAr = const [],
    this.applicableZoneNamesEn = const [],
    this.serviceId,
    this.serviceNameAr,
    this.serviceNameEn,
    this.serviceListPriceMinor = 0,
    this.targetPriceMinor = 0,
  });

  static List<String> _names(dynamic raw) => raw is List
      ? raw.whereType<String>().where((name) => name.isNotEmpty).toList()
      : const <String>[];

  factory OfferTermsModel.fromJson(Map<String, dynamic> json) {
    return OfferTermsModel(
      promoCode: json['promoCode'] as String?,
      discountType: json['discountType'] as String?,
      configuredValue: (json['configuredValue'] as num?)?.toInt() ?? 0,
      minOrderMinor: (json['minOrderMinor'] as num?)?.toInt() ?? 0,
      packageId: json['packageId'] as String?,
      packageNameAr: json['packageNameAr'] as String?,
      packageNameEn: json['packageNameEn'] as String?,
      packagePriceMinor: (json['packagePriceMinor'] as num?)?.toInt() ?? 0,
      packageNumWashes: (json['packageNumWashes'] as num?)?.toInt() ?? 0,
      packageValidityDays: (json['packageValidityDays'] as num?)?.toInt() ?? 0,
      applicableServiceNamesAr: _names(json['applicableServiceNamesAr']),
      applicableServiceNamesEn: _names(json['applicableServiceNamesEn']),
      applicableZoneNamesAr: _names(json['applicableZoneNamesAr']),
      applicableZoneNamesEn: _names(json['applicableZoneNamesEn']),
      serviceId: json['serviceId'] as String?,
      serviceNameAr: json['serviceNameAr'] as String?,
      serviceNameEn: json['serviceNameEn'] as String?,
      serviceListPriceMinor:
          (json['serviceListPriceMinor'] as num?)?.toInt() ?? 0,
      targetPriceMinor: (json['targetPriceMinor'] as num?)?.toInt() ?? 0,
    );
  }

  String? packageName({required bool isAr}) =>
      isAr ? packageNameAr : packageNameEn;

  String? serviceName({required bool isAr}) =>
      isAr ? serviceNameAr : serviceNameEn;

  List<String> applicableServices({required bool isAr}) =>
      isAr ? applicableServiceNamesAr : applicableServiceNamesEn;

  List<String> applicableZones({required bool isAr}) =>
      isAr ? applicableZoneNamesAr : applicableZoneNamesEn;
}

class CustomerOfferModel {
  final String id;
  final String offerType;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String? bannerArUrl;
  final String? bannerEnUrl;
  final DateTime endsAt;
  final OfferTermsModel terms;

  const CustomerOfferModel({
    required this.id,
    required this.offerType,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    this.bannerArUrl,
    this.bannerEnUrl,
    required this.endsAt,
    required this.terms,
  });

  static final DateTime endsAtFallback = DateTime.utc(9999, 12, 31);

  bool get isPromoCode => offerType == 'PROMO_CODE';

  bool get isService => offerType == 'SERVICE';

  bool get hasTargetPrice => isService && terms.targetPriceMinor > 0;

  String title({required bool isAr}) => isAr ? titleAr : titleEn;
  String description({required bool isAr}) =>
      isAr ? descriptionAr : descriptionEn;
  String? banner({required bool isAr}) => isAr ? bannerArUrl : bannerEnUrl;

  factory CustomerOfferModel.fromJson(Map<String, dynamic> json) {
    final rawTerms = json['terms'];
    final rawEndsAt = json['endsAt'] as String?;
    return CustomerOfferModel(
      id: json['id'] as String? ?? '',
      offerType: json['offerType'] as String? ?? 'PROMO_CODE',
      titleAr: json['titleAr'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      descriptionAr: json['descriptionAr'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      bannerArUrl: json['bannerArUrl'] as String?,
      bannerEnUrl: json['bannerEnUrl'] as String?,
      endsAt: tryParseWireDateTime(rawEndsAt) ?? endsAtFallback,
      terms: rawTerms is Map<String, dynamic>
          ? OfferTermsModel.fromJson(rawTerms)
          : const OfferTermsModel(),
    );
  }
}
