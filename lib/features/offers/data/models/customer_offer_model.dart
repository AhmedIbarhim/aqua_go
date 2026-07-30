import '../../../../core/utils/saudi_wire_format.dart';

/// Terms attached to a customer-visible offer. Exactly one THIRD is populated:
/// the promo third (promoCode / discountType / configuredValue / minOrderMinor)
/// for a PROMO_CODE offer, the package third for a PACKAGE offer, and the
/// service third (serviceId / serviceNameAr / serviceNameEn /
/// serviceListPriceMinor / targetPriceMinor) for a SERVICE offer. Mirrors the
/// backend record com.aquago.offer.api.records.OfferTerms.
///
/// The numeric fields are non-nullable with a 0 default so every consumer can
/// write `terms.minOrderMinor > 0` without a null branch; the absent half is
/// then simply all-zero. The identity fields (promoCode, discountType,
/// packageId, packageNameAr/En) stay nullable because "absent" and "empty" are
/// genuinely different for them.
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

  /// UCC23 step 6 — the services the linked promo code is restricted to, as
  /// bilingual NAMES rather than ids, index-aligned across the two languages.
  /// EMPTY means UNRESTRICTED, never "applies to nothing": a caller renders
  /// nothing at all for an empty list, not an empty section.
  final List<String> applicableServiceNamesAr;
  final List<String> applicableServiceNamesEn;

  /// UCC23 step 6 / A5 — the zones the linked promo code is restricted to.
  /// Stated whether or not the customer has a saved address: A5 SKIPS the zone
  /// rule for an address-less customer rather than failing it, and the offer is
  /// then shown "with its zone terms stated", enforced at apply time.
  final List<String> applicableZoneNamesAr;
  final List<String> applicableZoneNamesEn;

  /// The wash a SERVICE offer deep-links into. Null for the other two types.
  final String? serviceId;
  final String? serviceNameAr;
  final String? serviceNameEn;

  /// The service's current VAT-INCLUSIVE gross list price, in halala. 0 when
  /// this is not a SERVICE offer.
  final int serviceListPriceMinor;

  /// The VAT-INCLUSIVE gross price the wash BECOMES through this offer, in
  /// halala.
  ///
  /// 0 means there is NO deal — a SHORTCUT card that just jumps into booking
  /// the service at its list price. It never means "free". Ask
  /// [CustomerOfferModel.hasTargetPrice] rather than testing this number.
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

  /// A JSON array of strings, or an empty list for anything else — a missing,
  /// null or malformed payload reads as "unrestricted" rather than throwing.
  /// This is a read-reconstruction path: it must never tighten into a failure.
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

/// A customer-visible offer served by GET /api/public/offers. Mirrors the
/// backend record com.aquago.offer.api.records.CustomerOfferView.
///
/// NOTE: this is the REAL offer object, and now the only one — the home rails
/// render it directly. The banner-shaped placeholder model they used to carry
/// is gone; BannerModel (lib/features/home/data/models/banner_model.dart) is
/// the unrelated hero-carousel DTO.
class CustomerOfferModel {
  final String id;
  final String offerType;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String? bannerArUrl;
  final String? bannerEnUrl;
  /// When the offer stops being shown, in the Riyadh frame: UTC-flagged,
  /// carrying Asia/Riyadh wall-clock fields, exactly like [saudiNow]. Compare it
  /// only against another value in that frame, and format it WITHOUT `.toLocal()`
  /// — its fields are already the ones the customer should read.
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

  /// Fallback for an absent / unparseable `endsAt`. Far-future so the offer
  /// sorts LAST and renders no "Ends in N days" chip, rather than jumping to the
  /// top of the list as an epoch date would. The server always sends `endsAt`;
  /// this exists only so the read path can never throw.
  ///
  /// UTC-flagged, like every value in the Riyadh frame — see
  /// [tryParseWireDateTime].
  static final DateTime endsAtFallback = DateTime.utc(9999, 12, 31);

  bool get isPromoCode => offerType == 'PROMO_CODE';

  bool get isService => offerType == 'SERVICE';

  /// True when this offer actually discounts something. A SERVICE offer with a
  /// zero target is a pure shortcut card, NOT a free wash — 0 means "nothing to
  /// show", which is why callers must ask this rather than testing the number.
  bool get hasTargetPrice => isService && terms.targetPriceMinor > 0;

  String title({required bool isAr}) => isAr ? titleAr : titleEn;
  String description({required bool isAr}) => isAr ? descriptionAr : descriptionEn;
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
