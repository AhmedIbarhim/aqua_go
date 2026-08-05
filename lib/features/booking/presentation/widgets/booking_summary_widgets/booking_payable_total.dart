import '../../../../my_bookings/data/models/booking_response_model/breakdown.dart';

/// The amount the customer will actually be charged, in major units (SAR).
///
/// AQG-424 / AQG-425 — the booking summary used to read `Breakdown.gross`,
/// which falls back through `grossMinor` FIRST and is therefore the
/// PRE-discount subtotal. On a fully-discounted quote that reads 60.00 while
/// the customer owes nothing, so the "does this need payment?" decision
/// tested the wrong number and a free booking still opened the Moyasar SDK.
///
/// Preference order, most-specific first:
///   1. `amountDueMinor` — post-promo AND post-points. Present only when the
///      server computed a points reduction.
///   2. `totalMinor` — post-promo. The ordinary case.
///   3. `grossMinor` — the legacy fallback (`Breakdown.total` already does
///      this), so an older payload carrying only a gross never reads as free.
///
/// NOTE this is only ever an AFFORDANCE decision — which controls to show and
/// whether to enable the confirm button. The authoritative "is this free?"
/// answer is the server's `PaymentInitResponse.amountMinor`, and that is what
/// gates the SDK push. Client money math never decides whether a card is
/// charged.
double payableTotalMajor(Breakdown? breakdown) {
  if (breakdown == null) return 0.0;
  final minor =
      breakdown.amountDueMinor ??
      breakdown.totalMinor ??
      breakdown.grossMinor ??
      0;
  return minor / 100.0;
}
