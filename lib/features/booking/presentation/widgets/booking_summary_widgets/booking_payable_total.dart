import '../../../../my_bookings/data/models/booking_response_model/breakdown.dart';
import '../../../data/models/payment_init_model.dart';
import '../../../data/models/quote_model.dart';
import '../../../domain/configs/booking_flow_config.dart';

/// Whether the backend figure this screen prices everything from has landed.
///
/// It is fired from a post-frame callback, so the first frames of a priced
/// booking have none. Every figure on the summary — the payment affordance, the
/// breakdown card, the confirm button — has to wait for it together, because
/// each of them reads `quote?.<field> ?? 0` and a missing price is therefore
/// indistinguishable from a genuinely free order. One predicate, one moment:
/// while it is false the screen shows a placeholder and nothing can be
/// submitted; when it flips, every number appears at once and they all come
/// from the same locked figure.
///
/// **[quote] is not always a quote.** Two flows price from the server and only
/// one of them quotes:
///   * service — the `/quote` round trip (`config.requiresQuote`);
///   * package (subscription wash) — the read-only wash-charge preview,
///     which `BookingCubit.fetchWashChargePreview` maps into a SYNTHETIC
///     `QuoteModel` and publishes on the same `state.quote` field.
/// So the arrival that releases the gate is the same field either way, but the
/// question "is this flow waiting for one?" is NOT `requiresQuote` — that
/// answers "does it call /quote?". Gating on it left the package flow's gate
/// permanently open (`!requiresQuote` short-circuits), and the package summary
/// went on stating a fabricated SAR 0.00 subtotal, VAT and total for a wash
/// that costs money. [BookingFlowConfig.awaitsBackendPrice] is the readiness
/// question; `requiresQuote` stays the routing one.
///
/// `!awaitsBackendPrice` short-circuits the wait rather than blocking forever
/// on a flow that never asks the server for a price at all (reschedule, gift
/// redemption) — neither renders the payment summary, so neither has anything
/// to withhold, and gating them would disable a Confirm button waiting on a
/// figure that is never coming.
bool isPriceLocked({
  required BookingFlowConfig config,
  required QuoteModel? quote,
}) => !config.awaitsBackendPrice || quote != null;

/// What the payment summary should render — THREE states, not two.
///
/// [isPriceLocked] answers "may this screen state a figure?", which is the
/// question the Confirm gate asks and the only one it needs. It is not enough
/// for the section itself, because the two ways of NOT having a price are
/// different situations for the customer:
///   * [pending] — the call is out and an answer is coming. A shimmer is an
///     honest promise.
///   * [unavailable] — the call came back a failure. Nothing re-fires it: both
///     price calls are fired once, from `booking_summary_view`'s `initState`
///     post-frame callback, and the snackbar that announced the failure is
///     transient. Shimmering here promises a price that is never arriving, and
///     leaves a customer who looked away on a permanently loading screen with a
///     dead Confirm button and no way forward but to leave the flow.
///   * [ready] — a real server figure is on the state, and the card states it.
///
/// The distinction is why `priceLoadFailed` exists on the state at all: on a
/// flow that fires its price call from a post-frame callback, `quote == null`
/// covers both of the first two.
enum PriceDisplay {
  /// The price call is out; nothing has failed.
  pending,

  /// The price call FAILED and left no price behind. Offer a way to re-fire it.
  unavailable,

  /// A price is on the state and may be stated.
  ready,
}

/// Resolves the three states, for BOTH priced flows, from the one predicate the
/// Confirm gate already uses.
///
/// Deliberately delegating to [isPriceLocked] rather than restating its rule:
/// "may a figure be stated?" must have exactly one answer on this screen, and a
/// second copy of `!awaitsBackendPrice || quote != null` here would let the card
/// and the Confirm button disagree the next time either is touched.
///
/// A quote already on the state wins over [priceLoadFailed]. A reprice that
/// fails over an existing quote (a promo re-check, a points toggle) leaves that
/// quote in place, and it is still a real server figure for a real selection —
/// the dead end being escaped here is having NO price at all, so that card
/// stays and the failure is the snackbar's to report.
PriceDisplay resolvePriceDisplay({
  required BookingFlowConfig config,
  required QuoteModel? quote,
  required bool priceLoadFailed,
}) {
  if (isPriceLocked(config: config, quote: quote)) return PriceDisplay.ready;
  return priceLoadFailed ? PriceDisplay.unavailable : PriceDisplay.pending;
}

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
