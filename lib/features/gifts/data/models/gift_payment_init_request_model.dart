class GiftPaymentInitRequestModel {
  final String packageId;
  final String recipientPhone;
  final int? pointsToApply;
  final String? promoCode;
  final String attemptNonce;
  final List<String>? addOnIds;

  GiftPaymentInitRequestModel({
    required this.packageId,
    required this.recipientPhone,
    this.pointsToApply,
    this.promoCode,
    required this.attemptNonce,
    this.addOnIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      'recipientPhone': recipientPhone,
      if (pointsToApply != null) 'pointsToApply': pointsToApply,
      if (promoCode != null && promoCode!.isNotEmpty) 'promoCode': promoCode,
      'attemptNonce': attemptNonce,
      if (addOnIds != null && addOnIds!.isNotEmpty)
        'addOns': addOnIds!.map((id) => {'addonId': id}).toList(),
    };
  }
}
