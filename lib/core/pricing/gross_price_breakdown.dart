/// The ONE shape every price breakdown in the app renders.
///
/// Every figure here is VAT-INCLUSIVE (gross), in halala. That is the whole
/// point of this type: the customer is shown the prices they recognise from the
/// catalogue, the discount at the value they were promised, and one dominant
/// total. VAT is a disclosure UNDER the total, not a step in the sum.
///
/// The layout it drives, top to bottom:
///
///     <line>                 120.00     <- [lines], VAT-inclusive
///     <line>                  55.00
///     ─────────────────────────────
///     Total before discount  175.00     <- [subtotalMinor]; == Σ lines
///     Discount NEWCUST50     −50.00     <- [discountMinor], full gross value
///     Pay using points       −24.00     <- [pointsDiscountMinor]
///     ─────────────────────────────
///     Total                  101.00     <- [totalMinor], ALWAYS the emphasised
///                                          payable figure
///     Includes VAT            13.20     <- [vatMinor], muted, NOT an addend
///
/// With no discount the subtotal and discount rows BOTH disappear, leaving
/// lines → total → VAT footnote. There is never a `−0.00` row, and never a
/// "before discount" figure equal to the total.
///
/// **Points are a discount on the taxable base, exactly like a promo code —
/// NOT a separate tender.** The backend re-extracts VAT from the gross AFTER
/// both the promo discount and the loyalty-points discount, so [totalMinor] is
/// already points-net and IS what the customer pays. There is deliberately no
/// second "amount due" / "card charged" figure any more: it would always equal
/// [totalMinor] and would just be the same number stated twice. The points row
/// stays — it is one of the two discount rows that walk the subtotal down to
/// the total, the same as the promo row.
///
/// **No client-side tax maths.** Nothing here multiplies or divides by a VAT
/// rate. Every field is a backend figure, or an exact sum/difference of backend
/// figures in integer halala. Deriving a line's gross as `net × 1.15` on the
/// client would put rounding in two places and drift by halalas against the
/// amount actually charged.
library;

/// One VAT-inclusive display row: a service, or an add-on.
///
/// The DISCOUNT row is NOT a [GrossLine] — it is [GrossPriceBreakdown
/// .discountMinor], rendered once, below the subtotal. Modelling it as a line
/// would let it be summed into the subtotal it is supposed to be subtracted
/// from.
class GrossLine {
  /// Display label — the service or add-on name, already localised.
  final String label;

  /// VAT-inclusive amount for this line, in halala, BEFORE any discount.
  final int grossMinor;

  const GrossLine({required this.label, required this.grossMinor});

  double get gross => grossMinor / 100.0;
}

class GrossPriceBreakdown {
  /// The priced rows, VAT-inclusive and PRE-discount. Empty for a breakdown
  /// that has no itemisation to show (a covered subscription wash, a
  /// subscription package purchase), which renders total + VAT footnote alone.
  final List<GrossLine> lines;

  /// Gross total BEFORE the discount. Equal to Σ [lines] whenever there are
  /// lines — asserted by [linesReconcile].
  final int subtotalMinor;

  /// The discount as a POSITIVE magnitude, at its full VAT-inclusive value —
  /// the number the customer was promised. 0 when no code applied, which is
  /// what suppresses both the discount row and the subtotal row.
  final int discountMinor;

  /// The code that produced [discountMinor], folded into the discount row's
  /// label so no separate "Promo code" row is needed.
  final String? promoCode;

  /// The amount actually charged, VAT-inclusive — the backend's own
  /// authoritative payable figure, AFTER both the promo discount and the
  /// loyalty-points discount. Rendered verbatim as the Total row; never
  /// re-derived here.
  final int totalMinor;

  /// The VAT contained WITHIN [totalMinor] — the tax actually charged, which
  /// the backend computed on the gross AFTER both the promo discount and the
  /// loyalty-points discount. Never recomputed here.
  final int vatMinor;

  /// Optional wallet loyalty points discount in halala, already folded into
  /// [totalMinor] / [vatMinor] by the backend. Surfaced here only so its own
  /// row can render — it is not subtracted from anything on this type.
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

  /// A booking detail's breakdown.
  ///
  /// The backend already states this shape directly: on a booking whose booking
  /// carried a code it rebuilds the lines so the SERVICE row holds the
  /// PRE-discount wash price and a separate negative DISCOUNT line holds the
  /// saving, so Σ gross == the charged total. [itemLines] are that rebuild's
  /// SERVICE + ADDON rows, verbatim; nothing is derived.
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
      // Σ of the backend's own pre-discount rows. Falls back to the charged
      // total + discount when a booking carries no lines at all (a covered
      // wash), where there is nothing to sum and nothing to itemise.
      subtotalMinor: itemLines.isEmpty ? totalMinor + discountMinor : summed,
      discountMinor: discountMinor,
      promoCode: promoCode,
      totalMinor: totalMinor,
      vatMinor: vatMinor,
      pointsDiscountMinor: pointsDiscountMinor,
    );
  }

  // There is deliberately no `fromQuoteLines`.
  //
  // A quote used to net the discount INTO its lines and emit no DISCOUNT row,
  // so its SERVICE row was POST-discount and this file recovered the real price
  // as `serviceLine.gross + promoDiscount`. `PriceQuoteServiceImpl.buildLines`
  // now emits the SAME three-kind shape the booking detail always emitted —
  // pre-discount SERVICE + ADDON rows plus one negative DISCOUNT row — so both
  // surfaces go through [fromBookingLines] and the client adds nothing back.
  //
  // Two things went with it. The arithmetic: no figure on this type is derived
  // from another any more. And the "known limit" it carried — when the discount
  // outgrew the whole service line the backend spilled the remainder onto the
  // add-on rows, and the split was not on the wire, so the service row read too
  // high and the add-on rows too low while the column still reconciled. With
  // the saving on its own row there is no spill to attribute.
  //
  // It could not have survived TARGET_PRICE in any case: that discount is
  // LINE-scoped and sets the wash to a fixed price, so `charged + discount`
  // stops being a statement about the service line at all.

  // There is also deliberately no `amountDueMinor` / "card charged" figure any
  // more. It used to diverge from [totalMinor] when points were a TENDER that
  // reduced only the card charge, leaving the taxable total untouched. Points
  // are now a discount on the taxable base — exactly like the promo — so the
  // backend's `totalMinor` is already points-net and the wire's own
  // `amountDueMinor` field is defined to equal it exactly (kept server-side
  // only for back-compat). Carrying a second client-side field for a number
  // that always equals [totalMinor] would just be a duplicate payable row
  // waiting to happen again.

  /// True when a promo discount row should render.
  bool get hasDiscount => discountMinor > 0;

  /// True when a wallet points discount row should render.
  bool get hasPointsDiscount => pointsDiscountMinor > 0;

  /// Whether the visible line rows sum EXACTLY to the visible subtotal. The
  /// column is unreadable if they do not, so this is asserted in tests rather
  /// than papered over at render time.
  bool get linesReconcile =>
      lines.isEmpty ||
      lines.fold<int>(0, (s, l) => s + l.grossMinor) == subtotalMinor;

  /// Whether `subtotal − discount − points == total`, the one arithmetic
  /// statement this layout makes now that both discounts land on the same
  /// taxable-base ladder. Asserted in tests rather than trusted silently.
  bool get totalReconciles =>
      subtotalMinor - discountMinor - pointsDiscountMinor == totalMinor;

  double get subtotal => subtotalMinor / 100.0;
  double get discount => discountMinor / 100.0;
  double get pointsDiscount => pointsDiscountMinor / 100.0;
  double get total => totalMinor / 100.0;
  double get vat => vatMinor / 100.0;
}
