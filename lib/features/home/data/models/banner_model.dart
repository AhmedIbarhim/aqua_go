class BannerModel {
  final String id;
  final String locale;
  final String imageUrl;
  final String ctaType;
  final String? ctaTarget;
  final String? validFrom;
  final String? validTo;
  final int sortOrder;
  final String? currentPolicyVersion;

  BannerModel({
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

  /// Helper getter for backward compatibility with existing widgets using `.image`
  String get image => imageUrl;

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String? ?? '',
      locale: json['locale'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      ctaType: json['ctaType'] as String? ?? 'NONE',
      ctaTarget: json['ctaTarget'] as String?,
      validFrom: json['validFrom'] as String?,
      validTo: json['validTo'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      currentPolicyVersion: json['currentPolicyVersion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locale': locale,
      'imageUrl': imageUrl,
      'ctaType': ctaType,
      if (ctaTarget != null) 'ctaTarget': ctaTarget,
      if (validFrom != null) 'validFrom': validFrom,
      if (validTo != null) 'validTo': validTo,
      'sortOrder': sortOrder,
      if (currentPolicyVersion != null) 'currentPolicyVersion': currentPolicyVersion,
    };
  }
}
