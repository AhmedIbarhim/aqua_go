import '../../../my_bookings/data/models/booking_response_model/breakdown.dart';

class GiftQuoteModel {
  final int faceMinor;
  final Breakdown? breakdown;
  final String? promoCode;
  final int? promoDiscountMinor;
  final bool? promoAccepted;
  final String? promoRejectionReason;
  final int maxApplicablePoints;
  final int pointsApplied;
  final bool pointsClamped;
  final int pointsDiscountMinor;
  final int cardChargeMinor;
  final String currency;
  final List<GiftQuoteAddOn> addOns;

  GiftQuoteModel({
    required this.faceMinor,
    this.breakdown,
    this.promoCode,
    this.promoDiscountMinor,
    this.promoAccepted,
    this.promoRejectionReason,
    required this.maxApplicablePoints,
    required this.pointsApplied,
    required this.pointsClamped,
    required this.pointsDiscountMinor,
    required this.cardChargeMinor,
    required this.currency,
    required this.addOns,
  });

  factory GiftQuoteModel.fromJson(Map<String, dynamic> json) {
    return GiftQuoteModel(
      faceMinor: (json['faceMinor'] as num?)?.toInt() ?? 0,
      breakdown: json['breakdown'] != null
          ? Breakdown.fromJson(json['breakdown'] as Map<String, dynamic>)
          : null,
      promoCode: json['promoCode'] as String?,
      promoDiscountMinor: (json['promoDiscountMinor'] as num?)?.toInt(),
      promoAccepted: json['promoAccepted'] as bool?,
      promoRejectionReason: json['promoRejectionReason'] as String?,
      maxApplicablePoints: (json['maxApplicablePoints'] as num?)?.toInt() ?? 0,
      pointsApplied: (json['pointsApplied'] as num?)?.toInt() ?? 0,
      pointsClamped: json['pointsClamped'] as bool? ?? false,
      pointsDiscountMinor: (json['pointsDiscountMinor'] as num?)?.toInt() ?? 0,
      cardChargeMinor: (json['cardChargeMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'SAR',
      addOns: json['addOns'] != null
          ? (json['addOns'] as List)
                .map((e) => GiftQuoteAddOn.fromJson(e as Map<String, dynamic>))
                .toList()
          : <GiftQuoteAddOn>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'faceMinor': faceMinor,
    if (breakdown != null) 'breakdown': breakdown!.toJson(),
    if (promoCode != null) 'promoCode': promoCode,
    if (promoDiscountMinor != null) 'promoDiscountMinor': promoDiscountMinor,
    if (promoAccepted != null) 'promoAccepted': promoAccepted,
    if (promoRejectionReason != null)
      'promoRejectionReason': promoRejectionReason,
    'maxApplicablePoints': maxApplicablePoints,
    'pointsApplied': pointsApplied,
    'pointsClamped': pointsClamped,
    'pointsDiscountMinor': pointsDiscountMinor,
    'cardChargeMinor': cardChargeMinor,
    'currency': currency,
    'addOns': addOns.map((e) => e.toJson()).toList(),
  };

  // --- UI Helpers ---
  double get face => faceMinor / 100.0;
  double get pointsDiscount => pointsDiscountMinor / 100.0;
  double get promoDiscount => (promoDiscountMinor ?? 0) / 100.0;
  double get cardCharge => cardChargeMinor / 100.0;
}

class GiftQuoteAddOn {
  final String addonId;
  final String nameAr;
  final String nameEn;
  final int priceMinor;
  final String currency;

  GiftQuoteAddOn({
    required this.addonId,
    required this.nameAr,
    required this.nameEn,
    required this.priceMinor,
    required this.currency,
  });

  factory GiftQuoteAddOn.fromJson(Map<String, dynamic> json) {
    return GiftQuoteAddOn(
      addonId: json['addonId'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      priceMinor: (json['priceMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'SAR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addonId': addonId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'priceMinor': priceMinor,
      'currency': currency,
    };
  }
}
