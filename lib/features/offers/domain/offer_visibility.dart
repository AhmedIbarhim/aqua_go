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
/// Both instants are normalised to UTC before comparing: `endsAt` arrives UTC
/// from the API while [now] is typically a local `DateTime.now()`, and comparing
/// them as-is would drift by the Asia/Riyadh +03:00 offset.
///
/// Returns a NEW list; the caller's feed is never reordered in place.
List<CustomerOfferModel> visibleOffers(
  List<CustomerOfferModel> offers,
  DateTime now,
) {
  final nowUtc = now.toUtc();
  final live = offers
      .where((offer) => offer.endsAt.toUtc().isAfter(nowUtc))
      .toList();
  live.sort((a, b) => a.endsAt.toUtc().compareTo(b.endsAt.toUtc()));
  return live;
}
