class PendingOfferHandoff {
  const PendingOfferHandoff({required this.offerId});

  final String offerId;
}

class PendingPromoCode {
  PendingPromoCode._();

  static final PendingPromoCode instance = PendingPromoCode._();

  PendingOfferHandoff? _pending;

  void hold({required String offerId}) {
    final trimmedId = offerId.trim();
    _pending = trimmedId.isEmpty
        ? null
        : PendingOfferHandoff(offerId: trimmedId);
  }

  PendingOfferHandoff? takeHandoff() {
    final value = _pending;
    _pending = null;
    return value;
  }
}
