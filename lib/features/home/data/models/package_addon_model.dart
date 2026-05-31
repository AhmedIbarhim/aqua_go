class PackageAddonModel {
  final String addonId;
  final int qty;
  final int deltaPriceMinor;

  PackageAddonModel({
    required this.addonId,
    required this.qty,
    required this.deltaPriceMinor,
  });

  factory PackageAddonModel.fromJson(Map<String, dynamic> json) {
    return PackageAddonModel(
      addonId: json['addonId'] as String? ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      deltaPriceMinor: (json['deltaPriceMinor'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'addonId': addonId, 'qty': qty, 'deltaPriceMinor': deltaPriceMinor};
  }
}
