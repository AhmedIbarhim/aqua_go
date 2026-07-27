/// What the customer picked when they tapped "Use this code" on an offer.
///
/// Carries the OFFER id as well as the code because the two are not
/// interchangeable at the money boundary. The server binds a quote to an
/// `offerId` and writes it onto the redemption row, which is the only way a
/// sale can be attributed back to the offer that produced it — UCA22 A6 lets
/// two live offers point at the same promo code, so the code alone cannot say
/// which one the customer came through.
class PendingOfferHandoff {
  const PendingOfferHandoff({required this.offerId, required this.promoCode});

  /// The offer the customer opened. Sent to the quote so the server can bind
  /// the redemption to it.
  final String offerId;

  /// The code that offer carries, for display while the quote is in flight.
  final String promoCode;
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

  /// Holds [offerId] and its [promoCode] for the next quote, replacing anything
  /// previously held. A blank code is treated as nothing held — an offer with
  /// no code behind it cannot be applied.
  void hold({required String offerId, required String promoCode}) {
    final trimmedCode = promoCode.trim();
    final trimmedId = offerId.trim();
    _pending = (trimmedCode.isEmpty || trimmedId.isEmpty)
        ? null
        : PendingOfferHandoff(offerId: trimmedId, promoCode: trimmedCode);
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
