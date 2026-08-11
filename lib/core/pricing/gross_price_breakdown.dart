library;

class GrossLine {
  final String label;

  final int grossMinor;

  const GrossLine({required this.label, required this.grossMinor});

  double get gross => grossMinor / 100.0;
}

class GrossPriceBreakdown {
  final List<GrossLine> lines;

  final int subtotalMinor;

  final int discountMinor;

  final String? promoCode;

  final int totalMinor;

  final int vatMinor;

  final int pointsDiscountMinor;

  const GrossPriceBreakdown({
    required this.lines,
    required this.subtotalMinor,
    required this.discountMinor,
    required this.promoCode,
    required this.totalMinor,
    required this.vatMinor,
    this.pointsDiscountMinor = 0,
  });

  factory GrossPriceBreakdown.fromBookingLines({
    required List<GrossLine> itemLines,
    required int discountMinor,
    required String? promoCode,
    required int totalMinor,
    required int vatMinor,
    int pointsDiscountMinor = 0,
  }) {
    final summed = itemLines.fold<int>(0, (s, l) => s + l.grossMinor);
    return GrossPriceBreakdown(
      lines: itemLines,

      subtotalMinor: itemLines.isEmpty ? totalMinor + discountMinor : summed,
      discountMinor: discountMinor,
      promoCode: promoCode,
      totalMinor: totalMinor,
      vatMinor: vatMinor,
      pointsDiscountMinor: pointsDiscountMinor,
    );
  }

  bool get hasDiscount => discountMinor > 0;

  bool get hasPointsDiscount => pointsDiscountMinor > 0;

  bool get linesReconcile =>
      lines.isEmpty ||
      lines.fold<int>(0, (s, l) => s + l.grossMinor) == subtotalMinor;

  bool get totalReconciles =>
      subtotalMinor - discountMinor - pointsDiscountMinor == totalMinor;

  double get subtotal => subtotalMinor / 100.0;
  double get discount => discountMinor / 100.0;
  double get pointsDiscount => pointsDiscountMinor / 100.0;
  double get total => totalMinor / 100.0;
  double get vat => vatMinor / 100.0;
}
