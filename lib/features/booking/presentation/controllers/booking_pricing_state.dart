import 'package:equatable/equatable.dart';
import '../../data/models/quote_model.dart';
import 'booking_state.dart';

class BookingPricingState extends Equatable {
  final BookingStatus status;
  final String? errorMessage;
  final QuoteModel? quote;
  final bool priceLoadFailed;
  final String? appliedPromoCode;

  final String? appliedOfferId;

  final String? rememberedOfferId;

  final String? offerTitleAr;
  final String? offerTitleEn;

  final int? offerListPriceMinor;

  final int? offerTargetPriceMinor;

  const BookingPricingState({
    this.status = BookingStatus.initial,
    this.errorMessage,
    this.quote,
    this.priceLoadFailed = false,
    this.appliedPromoCode,
    this.appliedOfferId,
    this.rememberedOfferId,
    this.offerTitleAr,
    this.offerTitleEn,
    this.offerListPriceMinor,
    this.offerTargetPriceMinor,
  });

  BookingPricingState copyWith({
    BookingStatus? status,
    String? errorMessage,
    QuoteModel? quote,
    bool? priceLoadFailed,
    String? appliedPromoCode,
    String? appliedOfferId,
    String? rememberedOfferId,
    bool clearPromo = false,
    bool clearOfferId = false,
    bool clearOfferPrices = false,
    bool clearRememberedOffer = false,
  }) {
    return BookingPricingState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      quote: quote ?? this.quote,
      priceLoadFailed: priceLoadFailed ?? this.priceLoadFailed,
      appliedPromoCode: clearPromo
          ? null
          : (appliedPromoCode ?? this.appliedPromoCode),
      appliedOfferId: (clearPromo || clearOfferId)
          ? null
          : (appliedOfferId ?? this.appliedOfferId),
      rememberedOfferId: clearRememberedOffer
          ? null
          : (rememberedOfferId ?? this.rememberedOfferId),
      offerTitleAr: offerTitleAr,
      offerTitleEn: offerTitleEn,
      offerListPriceMinor: clearOfferPrices ? null : offerListPriceMinor,
      offerTargetPriceMinor: clearOfferPrices ? null : offerTargetPriceMinor,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    quote,
    priceLoadFailed,
    appliedPromoCode,
    appliedOfferId,
    rememberedOfferId,
    offerTitleAr,
    offerTitleEn,
    offerListPriceMinor,
    offerTargetPriceMinor,
  ];
}
