/// Response of `POST bookings/payment-init` (and the subscription mirror).
///
/// The server has re-validated the quote and soft-held the slot; it returns
/// the authoritative amount + the deterministic Moyasar `given_id` + the
/// metadata the SDK must stamp on the purchase so the create-time verify can
/// correlate it back to the quote (spec §4.2 / §9.5).
class PaymentInitModel {
  final int amountMinor;
  final String givenId;
  final String currency;
  final Map<String, dynamic> metadata;

  PaymentInitModel({
    required this.amountMinor,
    required this.givenId,
    required this.currency,
    required this.metadata,
  });

  factory PaymentInitModel.fromJson(Map<String, dynamic> json) {
    return PaymentInitModel(
      amountMinor: (json['amountMinor'] as num?)?.toInt() ?? 0,
      givenId: json['givenId'] as String? ?? '',
      currency: (json['currency'] as String?) ?? 'SAR',
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : <String, dynamic>{},
    );
  }
}
