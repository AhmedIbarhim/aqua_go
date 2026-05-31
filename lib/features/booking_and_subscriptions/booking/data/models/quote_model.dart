class QuoteModel {
  final String quoteId;
  final int totalMinor;
  final int vatMinor;
  final String currency;
  final DateTime expiresAt;
  final String? promoCode;
  final int promoDiscountMinor;

  QuoteModel({
    required this.quoteId,
    required this.totalMinor,
    required this.vatMinor,
    required this.currency,
    required this.expiresAt,
    this.promoCode,
    required this.promoDiscountMinor,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) => QuoteModel(
        quoteId: json['quoteId'] as String,
        totalMinor: json['totalMinor'] as int,
        vatMinor: json['vatMinor'] as int,
        currency: json['currency'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        promoCode: json['promoCode'] as String?,
        promoDiscountMinor: json['promoDiscountMinor'] as int,
      );

  Map<String, dynamic> toJson() => {
        'quoteId': quoteId,
        'totalMinor': totalMinor,
        'vatMinor': vatMinor,
        'currency': currency,
        'expiresAt': expiresAt.toIso8601String(),
        if (promoCode != null) 'promoCode': promoCode,
        'promoDiscountMinor': promoDiscountMinor,
      };
}
