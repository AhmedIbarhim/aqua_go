class GiftPaymentInitRequestModel {
  final String packageId;
  final String recipientPhone;
  final int? pointsToApply;
  final String? promoCode;
  final String attemptNonce;

  GiftPaymentInitRequestModel({
    required this.packageId,
    required this.recipientPhone,
    this.pointsToApply,
    this.promoCode,
    required this.attemptNonce,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      'recipientPhone': recipientPhone,
      if (pointsToApply != null) 'pointsToApply': pointsToApply,
      if (promoCode != null) 'promoCode': promoCode,
      'attemptNonce': attemptNonce,
    };
  }
}
