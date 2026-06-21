/// Server-supplied Moyasar SDK configuration.
///
/// Returned by GET /api/customer/payments/sdk-config.
/// The publishable key is safe to read from this endpoint — it is a
/// public key that can only originate payments, never refund/read.
class PaymentSdkConfigModel {
  final String publishableApiKey;
  final String currency;

  /// null when Apple Pay is not configured on the server (non-iOS builds or
  /// when the merchant-id is not yet registered in the Moyasar dashboard).
  final String? applePayMerchantId;
  final String? applePayLabel;

  const PaymentSdkConfigModel({
    required this.publishableApiKey,
    required this.currency,
    this.applePayMerchantId,
    this.applePayLabel,
  });

  factory PaymentSdkConfigModel.fromJson(Map<String, dynamic> json) {
    final applePayJson = json['applePay'] as Map<String, dynamic>?;
    return PaymentSdkConfigModel(
      publishableApiKey: (json['publishableApiKey'] as String?) ?? '',
      currency: (json['currency'] as String?) ?? 'SAR',
      applePayMerchantId: applePayJson?['merchantId'] as String?,
      applePayLabel: applePayJson?['label'] as String?,
    );
  }
}
