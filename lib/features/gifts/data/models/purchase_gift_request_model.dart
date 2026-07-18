class PurchaseGiftRequestModel {
  final String packageId;
  final String themeId;
  final String recipientPhone;
  final String recipientName;
  final String messageText;
  final String? scheduledDeliveryAt;
  final int? pointsToApply;
  final String? moyasarPaymentId;
  final String? promoCode;
  final String? attemptNonce;
  final List<String>? addOnIds;

  PurchaseGiftRequestModel({
    required this.packageId,
    required this.themeId,
    required this.recipientPhone,
    required this.recipientName,
    required this.messageText,
    this.scheduledDeliveryAt,
    this.pointsToApply,
    this.moyasarPaymentId,
    this.promoCode,
    this.attemptNonce,
    this.addOnIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      'themeId': themeId,
      'recipientPhone': recipientPhone,
      'recipientName': recipientName,
      'messageText': messageText,
      if (scheduledDeliveryAt != null)
        'scheduledDeliveryAt': scheduledDeliveryAt,
      if (pointsToApply != null) 'pointsToApply': pointsToApply,
      if (moyasarPaymentId != null) 'moyasarPaymentId': moyasarPaymentId,
      if (promoCode != null && promoCode!.isNotEmpty) 'promoCode': promoCode,
      if (attemptNonce != null && attemptNonce!.isNotEmpty)
        'attemptNonce': attemptNonce,
      if (addOnIds != null && addOnIds!.isNotEmpty)
        'addOns': addOnIds!.map((id) => {'addonId': id}).toList(),
    };
  }
}
