class OfferModel {
  final String id;
  final String locale;
  final String imageUrl;
  final String ctaType;
  final String? ctaTarget;
  final String? validFrom;
  final String? validTo;
  final int sortOrder;
  final String? currentPolicyVersion;

  OfferModel({
    required this.id,
    required this.locale,
    required this.imageUrl,
    required this.ctaType,
    this.ctaTarget,
    this.validFrom,
    this.validTo,
    required this.sortOrder,
    this.currentPolicyVersion,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] as String,
      locale: json['locale'] as String,
      imageUrl: json['imageUrl'] as String,
      ctaType: json['ctaType'] as String,
      ctaTarget: json['ctaTarget'] as String?,
      validFrom: json['validFrom'] as String?,
      validTo: json['validTo'] as String?,
      sortOrder: json['sortOrder'] as int,
      currentPolicyVersion: json['currentPolicyVersion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locale': locale,
      'imageUrl': imageUrl,
      'ctaType': ctaType,
      'ctaTarget': ctaTarget,
      'validFrom': validFrom,
      'validTo': validTo,
      'sortOrder': sortOrder,
      'currentPolicyVersion': currentPolicyVersion,
    };
  }
}
