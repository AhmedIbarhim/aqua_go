import '../data/models/customer_offer_model.dart';

/// The offers that may be rendered at [now], soonest-closing first.
///
/// UCC23 step 2 lists only offers "whose start/end window includes the current
/// date and time". The server applies that predicate when it answers, but the
/// answer is then held on screen: a customer can leave the offers list or the
/// home rail open, or background the app, long past the moment an offer closed.
/// Sorting by `endsAt` alone would keep the dead card rendered at the bottom of
/// the list, which is exactly the deal the customer will be refused at apply
/// time. So expiry is a FILTER, and the sort is what is left over.
///
/// `endsAt` is EXCLUSIVE — the field is documented on the backend record as
/// "when the offer stops being shown" — so an offer whose `endsAt` equals [now]
/// is already over.
///
/// [now] MUST be in the Riyadh frame — `saudiNow()`, never `DateTime.now()`.
/// `endsAt` arrives as a bare Riyadh wall clock and is parsed into that frame by
/// [tryParseWireDateTime]; `isAfter` and `compareTo` compare epoch microseconds,
/// so a `now` from a different frame drifts by the device's own offset. A
/// `.toUtc()` on either side does NOT rescue that — on an offset-less value it
/// is a no-op, which is precisely why the drift went unnoticed.
///
/// Returns a NEW list; the caller's feed is never reordered in place.
List<CustomerOfferModel> visibleOffers(
  List<CustomerOfferModel> offers,
  DateTime now,
) {
  final live = offers.where((offer) => offer.endsAt.isAfter(now)).toList();
  live.sort((a, b) => a.endsAt.compareTo(b.endsAt));
  return live;
}
