class SubscriptionPackageAddon {
  final String addonId;
  final String? code;
  final String? nameAr;
  final String? nameEn;
  final String? imageUrl;
  final String? currency;
  final String? kind;
  final int? unitPriceMinor;
  final int? freeQty;
  final int? maxQtyPerWash;

  SubscriptionPackageAddon({
    required this.addonId,
    this.code,
    this.nameAr,
    this.nameEn,
    this.imageUrl,
    this.currency,
    this.kind,
    this.unitPriceMinor,
    this.freeQty,
    this.maxQtyPerWash,
  });

  factory SubscriptionPackageAddon.fromJson(Map<String, dynamic> json) {
    return SubscriptionPackageAddon(
      addonId: json['addonId'] as String? ?? '',
      code: json['code'] as String?,
      nameAr: json['nameAr'] as String?,
      nameEn: json['nameEn'] as String?,
      imageUrl: json['imageUrl'] as String?,
      currency: json['currency'] as String?,
      kind: json['kind'] as String?,
      unitPriceMinor: (json['unitPriceMinor'] as num?)?.toInt(),
      freeQty: (json['freeQty'] as num?)?.toInt(),
      maxQtyPerWash: (json['maxQtyPerWash'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addonId': addonId,
      if (code != null) 'code': code,
      if (nameAr != null) 'nameAr': nameAr,
      if (nameEn != null) 'nameEn': nameEn,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (currency != null) 'currency': currency,
      if (kind != null) 'kind': kind,
      if (unitPriceMinor != null) 'unitPriceMinor': unitPriceMinor,
      if (freeQty != null) 'freeQty': freeQty,
      if (maxQtyPerWash != null) 'maxQtyPerWash': maxQtyPerWash,
    };
  }
}
