import '../../../../core/utils/saudi_wire_format.dart';
import '../../../my_bookings/data/models/booking_response_model/breakdown.dart';
import '../../../my_bookings/data/models/booking_response_model/quote_line.dart';

/// One basis point is 1/10 000, so an unscaled 1x multiplier is 10 000 bps.
/// The backend sends every pricing multiplier in this unit.
const int kMultiplierBpsUnit = 10000;

class QuoteModel {
  final String quoteId;
  final String currency;

  /// When the quote stops being chargeable, in the Riyadh frame: UTC-flagged,
  /// carrying Asia/Riyadh wall-clock fields, exactly like `saudiNow()`. Compare
  /// it only against `saudiNow()` — never `DateTime.now()`, whose epoch value
  /// slides with the device's timezone.
  final DateTime expiresAt;

  /// Time-of-day pricing multiplier in basis points (10 000 = 1x), applied to
  /// the base price before the zone and demand multipliers.
  final int timeMultiplierBps;

  /// Zone-level pricing multiplier in basis points (10 000 = 1x).
  final int zoneMultiplierBps;

  /// Real-time demand multiplier in basis points (10 000 = 1x), which rises when
  /// zone capacity utilisation passes its configured threshold.
  final int demandMultiplierBps;

  /// Pre-VAT subtotal in halala after all three multipliers, but BEFORE the
  /// promo discount and VAT.
  final int surgedSubtotalMinor;

  final Breakdown? breakdown;
  final List<QuoteLine> lines;
  final QuoteSurgeModel? surge;
  final QuotePromoModel? promo;
  final QuoteLoyaltyModel? loyalty;

  QuoteModel({
    required this.quoteId,
    required this.currency,
    required this.expiresAt,
    this.timeMultiplierBps = kMultiplierBpsUnit,
    this.zoneMultiplierBps = kMultiplierBpsUnit,
    this.demandMultiplierBps = kMultiplierBpsUnit,
    this.surgedSubtotalMinor = 0,
    this.breakdown,
    this.lines = const [],
    this.surge,
    this.promo,
    this.loyalty,
  });

  /// The VAT-inclusive gross of every ADDON row on this quote, in halala.
  ///
  /// A plain sum of backend figures — no VAT arithmetic, nothing derived. It
  /// exists because a SERVICE offer prices the WASH only, so a screen stating
  /// the offer's price has to add back what the add-ons on that same screen
  /// cost; the quote's own add-on rows are the only server-blessed source for
  /// that. 0 when nothing is selected, and 0 on a quote that carries no lines.
  int get addOnsGrossMinor =>
      lines.where((l) => l.isAddon).fold<int>(0, (sum, l) => sum + l.grossMinor);

  /// True when any multiplier moved the price off its base — i.e. the surged
  /// subtotal is not simply the base subtotal. The unscaled default is 10 000,
  /// so an absent multiplier reads as "no surge" rather than as free pricing.
  bool get isSurged =>
      timeMultiplierBps != kMultiplierBpsUnit ||
      zoneMultiplierBps != kMultiplierBpsUnit ||
      demandMultiplierBps != kMultiplierBpsUnit;

  // Read-reconstruction path: NEVER tighten. Every field degrades to a safe
  // default so a partial/legacy payload yields a usable model instead of a
  // TypeError that kills the booking screen. Money fields go through `num` so
  // a JSON double (1500.0) parses as cleanly as an int.
  factory QuoteModel.fromJson(Map<String, dynamic> json) => QuoteModel(
    quoteId: json['quoteId'] as String? ?? '',
    currency: json['currency'] as String? ?? 'SAR',
    expiresAt: tryParseWireDateTime(json['expiresAt'] as String?) ?? saudiNow(),
    timeMultiplierBps: (json['timeMultiplierBps'] as num?)?.toInt() ??
        (json['surge'] != null ? ((json['surge']['timeBps'] as num?)?.toInt() ?? kMultiplierBpsUnit) : kMultiplierBpsUnit),
    zoneMultiplierBps: (json['zoneMultiplierBps'] as num?)?.toInt() ??
        (json['surge'] != null ? ((json['surge']['zoneBps'] as num?)?.toInt() ?? kMultiplierBpsUnit) : kMultiplierBpsUnit),
    demandMultiplierBps: (json['demandMultiplierBps'] as num?)?.toInt() ??
        (json['surge'] != null ? ((json['surge']['demandBps'] as num?)?.toInt() ?? kMultiplierBpsUnit) : kMultiplierBpsUnit),
    surgedSubtotalMinor: (json['surgedSubtotalMinor'] as num?)?.toInt() ?? 0,
    breakdown: json['breakdown'] is Map<String, dynamic>
        ? Breakdown.fromJson(json['breakdown'] as Map<String, dynamic>)
        : null,
    lines: QuoteLine.listFromJson(json['lines']),
    surge: json['surge'] is Map<String, dynamic>
        ? QuoteSurgeModel.fromJson(json['surge'] as Map<String, dynamic>)
        : null,
    promo: json['promo'] is Map<String, dynamic>
        ? QuotePromoModel.fromJson(json['promo'] as Map<String, dynamic>)
        : null,
    loyalty: json['loyalty'] is Map<String, dynamic>
        ? QuoteLoyaltyModel.fromJson(json['loyalty'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'quoteId': quoteId,
    'currency': currency,
    'expiresAt': toWireDateTime(expiresAt),
    if (promoCode != null) 'promoCode': promoCode,
    'promoDiscountMinor': promoDiscountMinor,
    'timeMultiplierBps': timeMultiplierBps,
    'zoneMultiplierBps': zoneMultiplierBps,
    'demandMultiplierBps': demandMultiplierBps,
    'surgedSubtotalMinor': surgedSubtotalMinor,
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
  int? get pointsDiscountMinor =>
      loyalty?.pointsDiscountMinor ?? breakdown?.pointsDiscountMinor;
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

  factory QuoteSurgeModel.fromJson(Map<String, dynamic> json) =>
      QuoteSurgeModel(
        timeBps: (json['timeBps'] as num?)?.toInt() ?? 0,
        zoneBps: (json['zoneBps'] as num?)?.toInt() ?? 0,
        demandBps: (json['demandBps'] as num?)?.toInt() ?? 0,
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

  factory QuotePromoModel.fromJson(Map<String, dynamic> json) =>
      QuotePromoModel(
        code: json['code'] as String? ?? '',
        discountType: json['discountType'] as String? ?? '',
        percent: (json['percent'] as num?)?.toInt() ?? 0,
        fixedAmountMinor: (json['fixedAmountMinor'] as num?)?.toInt() ?? 0,
        discountMinor: (json['discountMinor'] as num?)?.toInt() ?? 0,
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

  factory QuoteLoyaltyModel.fromJson(
    Map<String, dynamic> json,
  ) => QuoteLoyaltyModel(
    currentBalancePoints: (json['currentBalancePoints'] as num?)?.toInt() ?? 0,
    currentBalanceValueMinor:
        (json['currentBalanceValueMinor'] as num?)?.toInt() ?? 0,
    maxApplicablePoints: (json['maxApplicablePoints'] as num?)?.toInt() ?? 0,
    discountMinorAtMax: (json['discountMinorAtMax'] as num?)?.toInt() ?? 0,
    pointsApplied: (json['pointsApplied'] as num?)?.toInt() ?? 0,
    pointsDiscountMinor: (json['pointsDiscountMinor'] as num?)?.toInt() ?? 0,
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
