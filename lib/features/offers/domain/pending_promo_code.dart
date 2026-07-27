/// What the customer picked when they tapped "Use this code" on an offer.
///
/// Carries the OFFER id and NOTHING else. The offer id is the only value that
/// travels: the server resolves the offer's own code, refuses a request that
/// carries both, and stamps the redemption with the offer that drove the sale —
/// UCA22 A6 lets two live offers point at the same promo code, so the code
/// alone cannot say which one the customer came through. Carrying the code
/// alongside would be a second, unusable copy of a value the wire never accepts.
class PendingOfferHandoff {
  const PendingOfferHandoff({required this.offerId});

  /// The offer the customer opened. Sent to the quote so the server can bind
  /// the redemption to it.
  final String offerId;
}

/// Single-shot, in-memory handoff from the offers surface into the booking
/// flow. The booking summary consumes it once, at the start of the next quote,
/// and the read clears it so an offer never silently re-applies to a later,
/// unrelated booking.
///
/// Deliberately NOT persisted: an offer can stop being eligible between app
/// launches, and a stale handoff would produce a confusing rejection at quote
/// time.
class PendingPromoCode {
  PendingPromoCode._();

  static final PendingPromoCode instance = PendingPromoCode._();

  PendingOfferHandoff? _pending;

  /// Holds [offerId] for the next quote, replacing anything previously held. A
  /// blank id is treated as nothing held — there is nothing for the server to
  /// resolve.
  void hold({required String offerId}) {
    final trimmedId = offerId.trim();
    _pending =
        trimmedId.isEmpty ? null : PendingOfferHandoff(offerId: trimmedId);
  }

  /// Returns what is held and clears it. Null when nothing is held.
  ///
  /// Reading is the ONLY way to empty the slot, and it is the whole point: the
  /// booking summary consumes the handoff at the start of the next quote, and
  /// a second quote must not silently re-apply an offer the customer picked for
  /// the first one.
  PendingOfferHandoff? takeHandoff() {
    final value = _pending;
    _pending = null;
    return value;
  }
}
