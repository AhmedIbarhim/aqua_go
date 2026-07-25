import '../../../my_bookings/data/models/booking_response_model/breakdown.dart';
import '../../../my_bookings/data/models/booking_response_model/quote_line.dart';

class QuoteModel {
  final String quoteId;
  final int totalMinor;
  final int vatMinor;
  final String currency;
  final DateTime expiresAt;
  final String? promoCode;
  final int promoDiscountMinor;
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
    this.breakdown,
    this.lines = const [],
  });

  // Read-reconstruction path: NEVER tighten. Every field degrades to a safe
  // default so a partial/legacy payload yields a usable model instead of a
  // TypeError that kills the booking screen. Money fields go through `num` so
  // a JSON double (1500.0) parses as cleanly as an int.
  factory QuoteModel.fromJson(Map<String, dynamic> json) => QuoteModel(
    quoteId: json['quoteId'] as String? ?? '',
    totalMinor: (json['totalMinor'] as num?)?.toInt() ?? 0,
    vatMinor: (json['vatMinor'] as num?)?.toInt() ?? 0,
    currency: json['currency'] as String? ?? 'SAR',
    expiresAt: json['expiresAt'] is String
        ? (DateTime.tryParse(json['expiresAt'] as String)?.toUtc() ??
              DateTime.now().toUtc())
        : DateTime.now().toUtc(),
    promoCode: json['promoCode'] as String?,
    promoDiscountMinor: (json['promoDiscountMinor'] as num?)?.toInt() ?? 0,
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
    'expiresAt': expiresAt.toIso8601String(),
    if (promoCode != null) 'promoCode': promoCode,
    'promoDiscountMinor': promoDiscountMinor,
    if (breakdown != null) 'breakdown': breakdown!.toJson(),
    'lines': lines.map((e) => e.toJson()).toList(),
  };
}
