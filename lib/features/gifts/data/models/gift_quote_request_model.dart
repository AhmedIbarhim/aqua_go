class GiftQuoteRequestModel {
  final String packageId;
  final int? pointsToApply;
  final String? promoCode;
  final List<String>? addOnIds;

  GiftQuoteRequestModel({
    required this.packageId,
    this.pointsToApply,
    this.promoCode,
    this.addOnIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      if (pointsToApply != null) 'pointsToApply': pointsToApply,
      if (promoCode != null && promoCode!.isNotEmpty) 'promoCode': promoCode,
      if (addOnIds != null && addOnIds!.isNotEmpty)
        'addOns': addOnIds!.map((id) => {'addonId': id}).toList(),
    };
  }
}
