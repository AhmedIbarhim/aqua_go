/// A single priced line in a quote or booking breakdown returned by the backend.
///
/// `kind` is "SERVICE" or "ADDON"; `refId` identifies the service or add-on.
/// `grossMinor` is VAT-inclusive; `netMinor` + `vatMinor` decompose it.
/// The backend guarantees Σ gross == total and Σ net/vat == breakdown.
/// The list is empty for covered (subscription) washes.
class QuoteLine {
  final String? kind;
  final String? refId;
  final int grossMinor;
  final int netMinor;
  final int vatMinor;

  QuoteLine({
    this.kind,
    this.refId,
    this.grossMinor = 0,
    this.netMinor = 0,
    this.vatMinor = 0,
  });

  QuoteLine.fromJson(Map<String, dynamic> json)
    : kind = json['kind'] as String?,
      refId = json['refId'] as String?,
      grossMinor = json['grossMinor'] != null
          ? int.tryParse(json['grossMinor'].toString()) ?? 0
          : 0,
      netMinor = json['netMinor'] != null
          ? int.tryParse(json['netMinor'].toString()) ?? 0
          : 0,
      vatMinor = json['vatMinor'] != null
          ? int.tryParse(json['vatMinor'].toString()) ?? 0
          : 0;

  Map<String, dynamic> toJson() => {
    'kind': kind,
    'refId': refId,
    'grossMinor': grossMinor,
    'netMinor': netMinor,
    'vatMinor': vatMinor,
  };

  static List<QuoteLine> listFromJson(dynamic json) {
    if (json is List) {
      return json
          .whereType<Map<String, dynamic>>()
          .map(QuoteLine.fromJson)
          .toList();
    }
    return const [];
  }

  // --- UI Helpers ---
  bool get isService => kind == 'SERVICE';
  bool get isAddon => kind == 'ADDON';
  double get gross => grossMinor / 100.0;
  double get net => netMinor / 100.0;
  double get vat => vatMinor / 100.0;
}
