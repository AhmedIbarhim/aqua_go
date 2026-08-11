class PaymentInitModel {
  final int amountMinor;
  final String givenId;
  final String currency;
  final Map<String, dynamic> metadata;
  final String? holdToken;

  PaymentInitModel({
    required this.amountMinor,
    required this.givenId,
    required this.currency,
    required this.metadata,
    this.holdToken,
  });

  factory PaymentInitModel.fromJson(Map<String, dynamic> json) {
    return PaymentInitModel(
      amountMinor: (json['amountMinor'] as num?)?.toInt() ?? 0,
      givenId: json['givenId'] as String? ?? '',
      currency: (json['currency'] as String?) ?? 'SAR',
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : <String, dynamic>{},
      holdToken: json['holdToken'] as String?,
    );
  }
}
