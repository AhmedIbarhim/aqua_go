import '../../data/models/quote_model.dart';

class QuoteRefresh {
  const QuoteRefresh({this.quote, this.droppedPromoReason});

  final QuoteModel? quote;

  final String? droppedPromoReason;

  bool get promoDropped => droppedPromoReason != null;
}

class OfferApplication {
  const OfferApplication({this.quote, this.settled = false});

  final QuoteModel? quote;

  final bool settled;

  bool get applied => quote != null;
}
