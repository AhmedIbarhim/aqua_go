class PromoPoints {
  String? promoCode;
  int? promoDiscountMinor;
  int? pointsApplied;
  int? pointsDiscountMinor;
  int? cardChargeMinor;
  String? currency;

  PromoPoints({
    this.promoCode,
    this.promoDiscountMinor,
    this.pointsApplied,
    this.pointsDiscountMinor,
    this.cardChargeMinor,
    this.currency,
  });

  PromoPoints.fromJson(Map<String, dynamic> json) {
    promoCode = json['promoCode'];
    promoDiscountMinor = json['promoDiscountMinor'];
    pointsApplied = json['pointsApplied'];
    pointsDiscountMinor = json['pointsDiscountMinor'];
    cardChargeMinor = json['cardChargeMinor'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['promoCode'] = promoCode;
    data['promoDiscountMinor'] = promoDiscountMinor;
    data['pointsApplied'] = pointsApplied;
    data['pointsDiscountMinor'] = pointsDiscountMinor;
    data['cardChargeMinor'] = cardChargeMinor;
    data['currency'] = currency;
    return data;
  }
}
