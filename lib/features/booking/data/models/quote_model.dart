import '../../../my_bookings/data/models/booking_response_model/breakdown.dart';
import '../../../my_bookings/data/models/booking_response_model/quote_line.dart';

class QuoteModel {
  final String quoteId;
  final String currency;
  final DateTime expiresAt;
  final Breakdown? breakdown;
  final List<QuoteLine> lines;
  final QuoteSurgeModel? surge;
  final QuotePromoModel? promo;
  final QuoteLoyaltyModel? loyalty;

  QuoteModel({
    required this.quoteId,
    required this.currency,
    required this.expiresAt,
    this.breakdown,
    this.lines = const [],
    this.surge,
    this.promo,
    this.loyalty,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) => QuoteModel(
    quoteId: json['quoteId'] as String,
    currency: json['currency'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
    breakdown: json['breakdown'] != null
        ? Breakdown.fromJson(json['breakdown'] as Map<String, dynamic>)
        : null,
    lines: QuoteLine.listFromJson(json['lines']),
    surge: json['surge'] != null
        ? QuoteSurgeModel.fromJson(json['surge'] as Map<String, dynamic>)
        : null,
    promo: json['promo'] != null
        ? QuotePromoModel.fromJson(json['promo'] as Map<String, dynamic>)
        : null,
    loyalty: json['loyalty'] != null
        ? QuoteLoyaltyModel.fromJson(json['loyalty'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'quoteId': quoteId,
    'currency': currency,
    'expiresAt': expiresAt.toIso8601String(),
    if (breakdown != null) 'breakdown': breakdown!.toJson(),
    'lines': lines.map((e) => e.toJson()).toList(),
    if (surge != null) 'surge': surge!.toJson(),
    if (promo != null) 'promo': promo!.toJson(),
    if (loyalty != null) 'loyalty': loyalty!.toJson(),
  };

  // Backwards compatibility getters
  int get totalMinor => breakdown?.totalMinor ?? breakdown?.grossMinor ?? 0;
  int get vatMinor => breakdown?.vatMinor ?? 0;
  String? get promoCode => promo?.code;
  int get promoDiscountMinor => breakdown?.promoDiscountMinor ?? 0;

  int? get maxApplicablePoints => loyalty?.maxApplicablePoints;
  int? get discountMinorAtMax => loyalty?.discountMinorAtMax;
  int? get currentBalancePoints => loyalty?.currentBalancePoints;
  int? get currentBalanceValueMinor => loyalty?.currentBalanceValueMinor;
  int? get pointsApplied => loyalty?.pointsApplied;
  int? get pointsDiscountMinor => loyalty?.pointsDiscountMinor ?? breakdown?.pointsDiscountMinor;
  int? get amountDueMinor => breakdown?.amountDueMinor;
}

class QuoteSurgeModel {
  final int timeBps;
  final int zoneBps;
  final int demandBps;

  QuoteSurgeModel({
    required this.timeBps,
    required this.zoneBps,
    required this.demandBps,
  });

  factory QuoteSurgeModel.fromJson(Map<String, dynamic> json) => QuoteSurgeModel(
    timeBps: json['timeBps'] as int,
    zoneBps: json['zoneBps'] as int,
    demandBps: json['demandBps'] as int,
  );

  Map<String, dynamic> toJson() => {
    'timeBps': timeBps,
    'zoneBps': zoneBps,
    'demandBps': demandBps,
  };
}

class QuotePromoModel {
  final String code;
  final String discountType;
  final int percent;
  final int fixedAmountMinor;
  final int discountMinor;

  QuotePromoModel({
    required this.code,
    required this.discountType,
    required this.percent,
    required this.fixedAmountMinor,
    required this.discountMinor,
  });

  factory QuotePromoModel.fromJson(Map<String, dynamic> json) => QuotePromoModel(
    code: json['code'] as String,
    discountType: json['discountType'] as String,
    percent: json['percent'] as int,
    fixedAmountMinor: json['fixedAmountMinor'] as int,
    discountMinor: json['discountMinor'] as int,
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'discountType': discountType,
    'percent': percent,
    'fixedAmountMinor': fixedAmountMinor,
    'discountMinor': discountMinor,
  };
}

class QuoteLoyaltyModel {
  final int currentBalancePoints;
  final int currentBalanceValueMinor;
  final int maxApplicablePoints;
  final int discountMinorAtMax;
  final int pointsApplied;
  final int pointsDiscountMinor;

  QuoteLoyaltyModel({
    required this.currentBalancePoints,
    required this.currentBalanceValueMinor,
    required this.maxApplicablePoints,
    required this.discountMinorAtMax,
    required this.pointsApplied,
    required this.pointsDiscountMinor,
  });

  factory QuoteLoyaltyModel.fromJson(Map<String, dynamic> json) => QuoteLoyaltyModel(
    currentBalancePoints: json['currentBalancePoints'] as int,
    currentBalanceValueMinor: json['currentBalanceValueMinor'] as int,
    maxApplicablePoints: json['maxApplicablePoints'] as int,
    discountMinorAtMax: json['discountMinorAtMax'] as int,
    pointsApplied: json['pointsApplied'] as int,
    pointsDiscountMinor: json['pointsDiscountMinor'] as int,
  );

  Map<String, dynamic> toJson() => {
    'currentBalancePoints': currentBalancePoints,
    'currentBalanceValueMinor': currentBalanceValueMinor,
    'maxApplicablePoints': maxApplicablePoints,
    'discountMinorAtMax': discountMinorAtMax,
    'pointsApplied': pointsApplied,
    'pointsDiscountMinor': pointsDiscountMinor,
  };
}
