class SubscriptionIncludedAllowance {
  final String addonId;
  final String? nameAr;
  final String? nameEn;
  final int totalQty;
  final int consumedQty;
  final int remainingQty;

  SubscriptionIncludedAllowance({
    required this.addonId,
    this.nameAr,
    this.nameEn,
    required this.totalQty,
    required this.consumedQty,
    required this.remainingQty,
  });

  factory SubscriptionIncludedAllowance.fromJson(Map<String, dynamic> json) {
    return SubscriptionIncludedAllowance(
      addonId: json['addonId'] as String? ?? '',
      nameAr: json['nameAr'] as String?,
      nameEn: json['nameEn'] as String?,
      totalQty: (json['totalQty'] as num?)?.toInt() ?? 0,
      consumedQty: (json['consumedQty'] as num?)?.toInt() ?? 0,
      remainingQty: (json['remainingQty'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addonId': addonId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'totalQty': totalQty,
      'consumedQty': consumedQty,
      'remainingQty': remainingQty,
    };
  }
}
