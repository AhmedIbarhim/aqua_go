class SubscriptionBreakdown {
  final int grossMinor;
  final int netMinor;
  final int vatMinor;
  final String currency;

  SubscriptionBreakdown({
    required this.grossMinor,
    required this.netMinor,
    required this.vatMinor,
    required this.currency,
  });

  factory SubscriptionBreakdown.fromJson(Map<String, dynamic> json) {
    return SubscriptionBreakdown(
      grossMinor: (json['grossMinor'] ?? json['gross_minor'] as num?)?.toInt() ?? 0,
      netMinor: (json['netMinor'] ?? json['net_minor'] as num?)?.toInt() ?? 0,
      vatMinor: (json['vatMinor'] ?? json['vat_minor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grossMinor': grossMinor,
      'netMinor': netMinor,
      'vatMinor': vatMinor,
      'currency': currency,
    };
  }
}
