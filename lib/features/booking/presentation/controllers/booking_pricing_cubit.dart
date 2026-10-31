import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../../data/mappers/wash_preview_quote_mapper.dart';
import '../../data/mappers/wash_schedule_body.dart';
import '../../data/models/quote_model.dart';
import '../../data/repos/booking_repository.dart';
import 'booking_cubit.dart';
import 'booking_pricing_state.dart';
import 'booking_results.dart';
import 'booking_state.dart';
import 'closed_safe_emit.dart';

export 'booking_results.dart';

/// Prices what [BookingCubit] has selected: quotes, promo codes, offers and the
/// wash charge preview.
class BookingPricingCubit extends Cubit<BookingPricingState>
    with ClosedSafeEmit<BookingPricingState> {
  final BookingRepository _bookingRepo;
  final BookingCubit _booking;

  BookingPricingCubit({
    required BookingRepository bookingRepo,
    required BookingCubit booking,
    String? offerTitleAr,
    String? offerTitleEn,
    int? offerListPriceMinor,
    int? offerTargetPriceMinor,
  }) : _bookingRepo = bookingRepo,
       _booking = booking,
       super(
         BookingPricingState(
           offerTitleAr: offerTitleAr,
           offerTitleEn: offerTitleEn,
           offerListPriceMinor: (offerListPriceMinor ?? 0) > 0
               ? offerListPriceMinor
               : null,
           offerTargetPriceMinor: (offerTargetPriceMinor ?? 0) > 0
               ? offerTargetPriceMinor
               : null,
         ),
       );

  void _emitFailure(
    String message, {
    bool? priceLoadFailed,
    bool clearOfferPrices = false,
    bool clearRememberedOffer = false,
  }) {
    emit(
      state.copyWith(
        status: BookingStatus.failure,
        errorMessage: message,
        priceLoadFailed: priceLoadFailed,
        clearOfferPrices: clearOfferPrices,
        clearRememberedOffer: clearRememberedOffer,
      ),
    );
  }

  /// Prices the current selection, optionally with a promo/offer/points.
  Future<QuoteModel?> fetchQuote({
    String? promoCode,
    String? offerId,
    int? pointsToApply,
  }) async {
    final result = await _priceAndPublish(
      promoCode: promoCode,
      offerId: offerId,
      pointsToApply: pointsToApply,
    );
    return result?.fold((_) => null, (quote) => quote);
  }

  /// Prices the current selection and publishes the outcome — the quote on the
  /// state on success, the server's message on it on rejection.
  Future<Either<Failure, QuoteModel>?> _priceAndPublish({
    String? promoCode,
    String? offerId,
    int? pointsToApply,
  }) async {
    if (!_booking.state.canPrice) return null;

    // The request is going out, so whatever an earlier attempt left behind is
    // no longer true: a retry in flight must show the shimmer, not the error it
    // is busy clearing.
    emit(state.copyWith(status: BookingStatus.loading, priceLoadFailed: false));

    final result = await _requestQuote(
      promoCode: promoCode,
      offerId: offerId,
      pointsToApply: pointsToApply,
    );

    result.fold(
      (failure) => _emitFailure(failure.message, priceLoadFailed: true),
      (quote) => _emitQuote(quote, offerId),
    );

    return result;
  }

  static bool _isPromoVerdict(FailureType type) =>
      type == FailureType.validation || type == FailureType.notFound;

  Future<Either<Failure, QuoteModel>> _requestQuote({
    String? promoCode,
    String? offerId,
    int? pointsToApply,
  }) {
    final selection = _booking.state;
    // A service booking carries a single vehicle, so car count is 1.
    const int carCount = 1;

    return _bookingRepo.getQuote(
      packageId: selection.selectedService!.id!,
      lat: selection.selectedAddress!.lat,
      lng: selection.selectedAddress!.lng,
      promoCode: promoCode,
      offerId: offerId,
      addOnIds: selection.selectedAddonIds,
      carCount: carCount,
      pointsToApply: pointsToApply,
    );
  }

  void _emitQuote(
    QuoteModel quote,
    String? offerId, {
    bool clearOfferPrices = false,
    bool clearRememberedOffer = false,
    bool rememberOffer = false,
  }) {
    final applied = quote.promoCode;
    emit(
      state.copyWith(
        status: BookingStatus.initial,
        quote: quote,
        priceLoadFailed: false,
        appliedPromoCode: applied,
        appliedOfferId: applied == null ? null : offerId,
        // Only an offer that actually PRICED something is worth offering back.
        // Null leaves any earlier remembered offer alone; dropping one is what
        // [clearRememberedOffer] is for.
        rememberedOfferId: (rememberOffer && applied != null) ? offerId : null,
        clearPromo: applied == null,
        clearOfferId: offerId == null,
        clearOfferPrices: clearOfferPrices,
        clearRememberedOffer: clearRememberedOffer,
      ),
    );
  }

  /// Applies a manually typed code to the current selection. The chip only
  /// lights up once the backend has returned a quote priced with it.
  Future<QuoteModel?> applyPromoCode(String code) =>
      fetchQuote(promoCode: code);

  Future<OfferApplication> applyOffer(String offerId) async {
    // Nothing to price yet, so nothing was asked of the server and the offer is
    // untouched.
    if (!_booking.state.canPrice) return const OfferApplication();

    emit(state.copyWith(status: BookingStatus.loading, priceLoadFailed: false));

    var result = await _requestQuote(offerId: offerId);
    final unanswered = result.fold(
      (failure) => !_isPromoVerdict(failure.type),
      (_) => false,
    );
    if (unanswered) {
      result = await _requestQuote(offerId: offerId);
    }

    return result.fold(
      (failure) {
        final settled = _isPromoVerdict(failure.type);
        _emitFailure(
          failure.message,
          // A SETTLED failure is the server REFUSING the offer, so its prices
          // and the remembered offer go with it.
          clearOfferPrices: settled,
          clearRememberedOffer: settled,
        );
        return OfferApplication(settled: settled);
      },
      (quote) {
        _emitQuote(quote, offerId, rememberOffer: true);
        return OfferApplication(quote: quote, settled: true);
      },
    );
  }

  /// Re-prices without any promo and clears the applied code.
  Future<QuoteModel?> removePromoCode() => fetchQuote();

  Future<QuoteModel?> repriceForDisplayWithoutPromo() async {
    if (!_booking.state.canPrice) return null;

    emit(state.copyWith(status: BookingStatus.loading));
    final result = await _requestQuote();

    return result.fold(
      (failure) {
        _emitFailure(failure.message);
        return null;
      },
      (quote) {
        emit(state.copyWith(status: BookingStatus.initial, quote: quote));
        return quote;
      },
    );
  }

  Future<QuoteRefresh> reprice() async {
    if (!_booking.state.canPrice) return const QuoteRefresh();

    final promoCode = state.appliedPromoCode;
    final offerId = state.appliedOfferId;

    // Same reason as `_priceAndPublish`: the attempt is live again, so the
    // failed-price state it may be recovering from is cleared on the way out.
    emit(state.copyWith(status: BookingStatus.loading, priceLoadFailed: false));
    final result = await _requestQuote(promoCode: promoCode, offerId: offerId);

    return result.fold(
      (rejection) =>
          _repriceAfter(rejection, promoCode: promoCode, offerId: offerId),
      (quote) async {
        _emitQuote(quote, offerId);
        return QuoteRefresh(quote: quote);
      },
    );
  }

  Future<QuoteRefresh> _repriceAfter(
    Failure rejection, {
    required String? promoCode,
    required String? offerId,
  }) async {
    // Nothing applied means there is nothing to drop and nothing to retry
    // differently; an unanswered request means there is nothing to drop it
    // OVER. Either way the failure is the whole story, and `copyWith` leaves
    // the applied code and offer exactly where they were.
    if (promoCode == null || !_isPromoVerdict(rejection.type)) {
      _emitFailure(rejection.message, priceLoadFailed: true);
      return const QuoteRefresh();
    }

    final offerRefused = offerId != null;

    final clean = await _requestQuote();
    return clean.fold(
      (failure) {
        _emitFailure(
          failure.message,
          // Both attempts are spent and neither produced a price.
          priceLoadFailed: true,
          clearOfferPrices: offerRefused,
          clearRememberedOffer: offerRefused,
        );
        return const QuoteRefresh();
      },
      (quote) {
        _emitQuote(
          quote,
          null,
          clearOfferPrices: offerRefused,
          clearRememberedOffer: offerRefused,
        );
        return QuoteRefresh(
          quote: quote,
          droppedPromoReason: rejection.message,
        );
      },
    );
  }

  Future<QuoteModel?> fetchWashChargePreview() async {
    final selection = _booking.state;
    final subscriptionId = selection.subscriptionId;
    final washId = selection.washId;
    if (subscriptionId == null || washId == null) return null;

    // The preview is going out — clear any earlier failure so a retry in flight
    // reads as pending, exactly as the service flow's quote does.
    emit(state.copyWith(status: BookingStatus.loading, priceLoadFailed: false));

    final result = await _bookingRepo.previewScheduleSubscriptionWash(
      subscriptionId: subscriptionId,
      washId: washId,
      scheduleData: washScheduleBody(
        vehicleId: selection.selectedCar?.id,
        addOnIds: selection.selectedAddonIds,
      ),
    );

    return result.fold(
      (failure) {
        _emitFailure(failure.message, priceLoadFailed: true);
        return null;
      },
      (data) {
        final quote = washPreviewQuoteFrom(data);
        emit(
          state.copyWith(
            status: BookingStatus.initial,
            quote: quote,
            priceLoadFailed: false,
          ),
        );
        return quote;
      },
    );
  }

  /// The offer has been spent on a booking. Nothing downstream of a created
  /// booking may offer it back.
  void forgetOffer() {
    emit(state.copyWith(clearRememberedOffer: true));
  }
}
