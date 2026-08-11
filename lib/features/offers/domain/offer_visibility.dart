import '../data/models/customer_offer_model.dart';

List<CustomerOfferModel> visibleOffers(
  List<CustomerOfferModel> offers,
  DateTime now,
) {
  final live = offers.where((offer) => offer.endsAt.isAfter(now)).toList();
  live.sort((a, b) => a.endsAt.compareTo(b.endsAt));
  return live;
}
