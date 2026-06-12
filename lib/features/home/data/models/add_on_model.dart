class AddOnModel {
  String? id;
  String? code;
  String? nameAr;
  String? nameEn;
  int? priceMinor;
  String? currency;
  String? imageUrl;

  // Package-specific properties (null for standard Service bookings)
  int? freeQty;
  int? maxQtyPerWash;
  int? qty;
  String? kind;

  AddOnModel({
    this.id,
    this.code,
    this.nameAr,
    this.nameEn,
    this.priceMinor,
    this.currency,
    this.imageUrl,
    this.freeQty,
    this.maxQtyPerWash,
    this.qty,
    this.kind,
  });

  AddOnModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['addonId'];
    code = json['code'];
    nameAr = json['nameAr'];
    nameEn = json['nameEn'];
    priceMinor =
        json['priceMinor'] ?? json['unitPriceMinor'] ?? json['priceMinor'];
    currency = json['currency'];
    imageUrl = json['imageUrl'];
    freeQty = json['freeQty'];
    maxQtyPerWash = json['maxQtyPerWash'];
    qty = json['qty'];
    kind = json['kind'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['nameAr'] = nameAr;
    data['nameEn'] = nameEn;
    data['priceMinor'] = priceMinor;
    data['currency'] = currency;
    data['imageUrl'] = imageUrl;
    data['freeQty'] = freeQty;
    data['maxQtyPerWash'] = maxQtyPerWash;
    data['qty'] = qty;
    data['kind'] = kind;

    return data;
  }

  double get price => ((priceMinor ?? 0) / 100);

  bool get isPackageAddon => freeQty != null || maxQtyPerWash != null;
}
