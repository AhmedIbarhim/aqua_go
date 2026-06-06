class Breakdown {
  int? grossMinor;
  int? netMinor;
  int? vatMinor;
  String? currency;

  Breakdown({this.grossMinor, this.netMinor, this.vatMinor, this.currency});

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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['grossMinor'] = grossMinor;
    data['netMinor'] = netMinor;
    data['vatMinor'] = vatMinor;
    data['currency'] = currency;
    return data;
  }

  // --- UI Helpers ---
  double get gross => (grossMinor ?? 0) / 100.0;
  double get net => (netMinor ?? 0) / 100.0;
  double get vat => (vatMinor ?? 0) / 100.0;
}
