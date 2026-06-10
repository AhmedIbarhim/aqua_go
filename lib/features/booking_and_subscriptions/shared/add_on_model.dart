class AddOnModel {
  String? id;
  String? nameAr;
  String? nameEn;
  int? priceMinor;
  String? currency;
  String? imageUrl;

  AddOnModel({
    this.id,
    this.nameAr,
    this.nameEn,
    this.priceMinor,
    this.currency,
    this.imageUrl,
  });

  AddOnModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameAr = json['nameAr'];
    nameEn = json['nameEn'];
    priceMinor = json['priceMinor'];
    currency = json['currency'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nameAr'] = nameAr;
    data['nameEn'] = nameEn;
    data['priceMinor'] = priceMinor;
    data['currency'] = currency;
    data['imageUrl'] = imageUrl;

    return data;
  }

  double get price => ((priceMinor ?? 0) / 100);
}
