import '../../../../core/utils/saudi_wire_format.dart';
import '../../../my_bookings/data/models/booking_response_model/breakdown.dart';
import '../../../my_bookings/data/models/booking_response_model/quote_line.dart';

/// One basis point is 1/10 000, so an unscaled 1x multiplier is 10 000 bps.
/// The backend sends every pricing multiplier in this unit.
const int kMultiplierBpsUnit = 10000;

class QuoteModel {
  final String quoteId;
  final int totalMinor;
  final int vatMinor;
  final String currency;

  /// When the quote stops being chargeable, in the Riyadh frame: UTC-flagged,
  /// carrying Asia/Riyadh wall-clock fields, exactly like `saudiNow()`. Compare
  /// it only against `saudiNow()` — never `DateTime.now()`, whose epoch value
  /// slides with the device's timezone.
  final DateTime expiresAt;
  final String? promoCode;
  final int promoDiscountMinor;

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

  QuoteModel({
    required this.quoteId,
    required this.totalMinor,
    required this.vatMinor,
    required this.currency,
    required this.expiresAt,
    this.promoCode,
    required this.promoDiscountMinor,
    this.timeMultiplierBps = kMultiplierBpsUnit,
    this.zoneMultiplierBps = kMultiplierBpsUnit,
    this.demandMultiplierBps = kMultiplierBpsUnit,
    this.surgedSubtotalMinor = 0,
    this.breakdown,
    this.lines = const [],
  });

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
    totalMinor: (json['totalMinor'] as num?)?.toInt() ?? 0,
    vatMinor: (json['vatMinor'] as num?)?.toInt() ?? 0,
    currency: json['currency'] as String? ?? 'SAR',
    // The wire value is a BARE Riyadh wall clock. `DateTime.tryParse` alone
    // returns a device-local instant, so the quote used to stay "valid" ~3h past
    // expiry on a UTC device and expire ~2h early on UTC+5; a trailing `.toUtc()`
    // is a no-op on an offset-less string and never fixed it. An absent value
    // degrades to "expired now", which forces a re-quote rather than charging
    // against a total nobody can vouch for.
    expiresAt:
        tryParseWireDateTime(json['expiresAt'] as String?) ?? saudiNow(),
    promoCode: json['promoCode'] as String?,
    promoDiscountMinor: (json['promoDiscountMinor'] as num?)?.toInt() ?? 0,
    // An absent multiplier reads as UNSCALED (10 000 bps = 1x), never as 0 —
    // which on this read-reconstruction path would describe a free wash.
    timeMultiplierBps:
        (json['timeMultiplierBps'] as num?)?.toInt() ?? kMultiplierBpsUnit,
    zoneMultiplierBps:
        (json['zoneMultiplierBps'] as num?)?.toInt() ?? kMultiplierBpsUnit,
    demandMultiplierBps:
        (json['demandMultiplierBps'] as num?)?.toInt() ?? kMultiplierBpsUnit,
    surgedSubtotalMinor: (json['surgedSubtotalMinor'] as num?)?.toInt() ?? 0,
    breakdown: json['breakdown'] is Map<String, dynamic>
        ? Breakdown.fromJson(json['breakdown'] as Map<String, dynamic>)
        : null,
    lines: QuoteLine.listFromJson(json['lines']),
  );

  Map<String, dynamic> toJson() => {
    'quoteId': quoteId,
    'totalMinor': totalMinor,
    'vatMinor': vatMinor,
    'currency': currency,
    // Bare Riyadh wall clock, the shape the backend emits and accepts.
    // `toIso8601String()` would stamp a `Z` on the UTC-flagged Riyadh frame and
    // mis-date the value by three hours on the way back out.
    'expiresAt': toWireDateTime(expiresAt),
    if (promoCode != null) 'promoCode': promoCode,
    'promoDiscountMinor': promoDiscountMinor,
    'timeMultiplierBps': timeMultiplierBps,
    'zoneMultiplierBps': zoneMultiplierBps,
    'demandMultiplierBps': demandMultiplierBps,
    'surgedSubtotalMinor': surgedSubtotalMinor,
    if (breakdown != null) 'breakdown': breakdown!.toJson(),
    'lines': lines.map((e) => e.toJson()).toList(),
  };
}
