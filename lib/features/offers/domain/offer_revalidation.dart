import '../data/models/customer_offer_model.dart';

sealed class OfferRevalidation {
  const OfferRevalidation();
}

final class OfferStillLive extends OfferRevalidation {
  const OfferStillLive(this.offer);

  final CustomerOfferModel offer;
}

final class OfferGone extends OfferRevalidation {
  const OfferGone();
}

final class OfferUncheckable extends OfferRevalidation {
  const OfferUncheckable();
}
