class PurchaseGiftRequestModel {
  final String packageId;
  final String themeId;
  final String recipientPhone;
  final String paymentMethod;
  final String? savedCardTokenId;
  final String recipientName;
  final String messageText;
  final String? scheduledDeliveryAt;
  final int? pointsToApply;
  final String? moyasarPaymentId;
  final List<String>? addOnIds;

  PurchaseGiftRequestModel({
    required this.packageId,
    required this.themeId,
    required this.recipientPhone,
    required this.paymentMethod,
    this.savedCardTokenId,
    required this.recipientName,
    required this.messageText,
    this.scheduledDeliveryAt,
    this.pointsToApply,
    this.moyasarPaymentId,
    this.addOnIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      'themeId': themeId,
      'recipientPhone': recipientPhone,
      'paymentMethod': paymentMethod,
      if (savedCardTokenId != null) 'savedCardTokenId': savedCardTokenId,
      'recipientName': recipientName,
      'messageText': messageText,
      if (scheduledDeliveryAt != null)
        'scheduledDeliveryAt': scheduledDeliveryAt,
      if (pointsToApply != null) 'pointsToApply': pointsToApply,
      if (moyasarPaymentId != null) 'moyasarPaymentId': moyasarPaymentId,
      if (addOnIds != null && addOnIds!.isNotEmpty) 'addOnIds': addOnIds,
    };
  }
}
