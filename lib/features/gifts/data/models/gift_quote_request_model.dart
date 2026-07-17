class GiftQuoteRequestModel {
  final String packageId;
  final int? pointsToApply;

  GiftQuoteRequestModel({
    required this.packageId,
    this.pointsToApply,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      if (pointsToApply != null) 'pointsToApply': pointsToApply,
    };
  }
}
