class Breakdown {
  int? grossMinor;
  int? netMinor;
  int? vatMinor;
  String? currency;

  // New quote breakdown fields
  int? surgedSubtotalMinor;
  int? promoDiscountMinor;
  int? totalMinor;
  int? pointsDiscountMinor;
  int? amountDueMinor;

  Breakdown({
    this.grossMinor,
    this.netMinor,
    this.vatMinor,
    this.currency,
    this.surgedSubtotalMinor,
    this.promoDiscountMinor,
    this.totalMinor,
    this.pointsDiscountMinor,
    this.amountDueMinor,
  });

  Breakdown.fromJson(Map<String, dynamic> json) {
    grossMinor = json['grossMinor'] != null
        ? int.tryParse(json['grossMinor'].toString())
        : null;
    netMinor = json['netMinor'] != null
        ? int.tryParse(json['netMinor'].toString())
        : null;
    vatMinor = json['vatMinor'] != null
        ? int.tryParse(json['vatMinor'].toString())
        : null;
    currency = json['currency'];
    surgedSubtotalMinor = json['surgedSubtotalMinor'] != null
        ? int.tryParse(json['surgedSubtotalMinor'].toString())
        : null;
    promoDiscountMinor = json['promoDiscountMinor'] != null
        ? int.tryParse(json['promoDiscountMinor'].toString())
        : null;
    totalMinor = json['totalMinor'] != null
        ? int.tryParse(json['totalMinor'].toString())
        : null;
    pointsDiscountMinor = json['pointsDiscountMinor'] != null
        ? int.tryParse(json['pointsDiscountMinor'].toString())
        : null;
    amountDueMinor = json['amountDueMinor'] != null
        ? int.tryParse(json['amountDueMinor'].toString())
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['grossMinor'] = grossMinor;
    data['netMinor'] = netMinor;
    data['vatMinor'] = vatMinor;
    data['currency'] = currency;
    data['surgedSubtotalMinor'] = surgedSubtotalMinor;
    data['promoDiscountMinor'] = promoDiscountMinor;
    data['totalMinor'] = totalMinor;
    data['pointsDiscountMinor'] = pointsDiscountMinor;
    data['amountDueMinor'] = amountDueMinor;
    return data;
  }

  // --- UI Helpers ---
  double get gross => ((grossMinor ?? totalMinor) ?? 0) / 100.0;
  double get net => (netMinor ?? 0) / 100.0;
  double get vat => (vatMinor ?? 0) / 100.0;
  double get surgedSubtotal => (surgedSubtotalMinor ?? 0) / 100.0;
  double get promoDiscount => (promoDiscountMinor ?? 0) / 100.0;
  double get total => ((totalMinor ?? grossMinor) ?? 0) / 100.0;
  double get pointsDiscount => (pointsDiscountMinor ?? 0) / 100.0;
  double get amountDue => (amountDueMinor ?? 0) / 100.0;
}
