import '../../../../my_bookings/data/models/booking_response_model/breakdown.dart';
import '../../../data/models/payment_init_model.dart';

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

/// Whether the summary should SHOW a payment-method picker and require one
/// before the confirm button enables.
///
/// AQG-424 / AQG-425 — this used to be
/// `config.requiresPaymentMethod || total > 0 || hasPayableAddon`, and
/// `requiresPaymentMethod` is unconditionally `true` for a service booking
/// (`booking_flow_config.dart:41`). The first term therefore made the other
/// two dead code on the main flow: a fully-discounted booking still demanded
/// a card and still pushed the Moyasar SDK on a SAR 0.00 charge.
///
/// An AFFORDANCE decision only. It decides what the customer SEES. It does
/// not decide whether a card is charged — see [shouldOpenPaymentSdk].
bool needsPaymentMethod({
  required double payableTotal,
  required bool hasPayableAddon,
}) => payableTotal > 0 || hasPayableAddon;

/// Whether to push `MoyasarPaymentView` — the AUTHORITATIVE charge decision.
///
/// Keyed on the SERVER's re-priced figure (`PaymentInitResponse.amountMinor`,
/// `BookingServiceImpl.paymentInit`), never on the client's own total. The
/// server re-validates the quote at payment-init and returns
/// `quote.totalMinor() - pointsDiscount`; if the client's arithmetic and the
/// server's ever disagree, the server wins and the customer is charged what
/// the server says.
///
/// This covers BOTH card-less lanes with one rule: a promo that zeroed the
/// total, and a loyalty hold that fully covered it. Neither needs its own
/// branch, because both arrive here as `amountMinor == 0`.
bool shouldOpenPaymentSdk(PaymentInitModel init) => init.amountMinor > 0;
