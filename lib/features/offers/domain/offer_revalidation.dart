import '../data/models/customer_offer_model.dart';

/// The outcome of the UCC23 A2 re-validation performed when the customer taps
/// an offer's primary action.
///
/// Three outcomes, not two, because "the server says this offer is gone" and
/// "I could not reach the server" must not produce the same message. Telling a
/// customer on a flaky connection that their offer expired is a lie that costs
/// them the deal.
sealed class OfferRevalidation {
  const OfferRevalidation();
}

/// The offer is still live. Carries the FRESHLY fetched copy — the terms may
/// have moved since the list was drawn, and it is the fresh one the customer
/// is about to act on.
final class OfferStillLive extends OfferRevalidation {
  const OfferStillLive(this.offer);

  final CustomerOfferModel offer;
}

/// The server answered 404 — the offer is absent, out of window, or no longer
/// eligible for this customer. UCC23 makes those three deliberately
/// indistinguishable, and the customer is told only that it is no longer
/// available. A2: block the action, refresh the list, show a brief toast.
final class OfferGone extends OfferRevalidation {
  const OfferGone();
}

/// The check itself failed — no network, a timeout, a 5xx. The action is
/// allowed to continue on the copy already held: BR-OFR-11 puts the real gate
/// at apply time, where UCC16 rejects an offer that has become ineligible, so
/// an unreachable server must not cost the customer an offer that is fine.
final class OfferUncheckable extends OfferRevalidation {
  const OfferUncheckable();
}
