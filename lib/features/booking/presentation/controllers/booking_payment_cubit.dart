import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../../../../core/utils/saudi_wire_format.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../../../subscriptions/data/repos/subscriptions_repository.dart';
import '../../data/mappers/wash_schedule_body.dart';
import '../../data/models/payment_init_model.dart';
import '../../data/repos/booking_repository.dart';
import '../../domain/booking_submission.dart';
import '../../domain/strategies/booking_submit_strategy.dart';
import 'booking_cubit.dart';
import 'booking_payment_state.dart';
import 'booking_pricing_cubit.dart';
import 'booking_state.dart';
import 'closed_safe_emit.dart';

/// Takes the selected, priced booking through payment and creation.
class BookingPaymentCubit extends Cubit<BookingPaymentState>
    with ClosedSafeEmit<BookingPaymentState> {
  final BookingRepository _bookingRepo;
  final SubscriptionsRepository _subscriptionsRepo;
  final BookingSubmitStrategy _submitStrategy;
  final BookingCubit _booking;
  final BookingPricingCubit _pricing;

  BookingPaymentCubit({
    required BookingRepository bookingRepo,
    required SubscriptionsRepository subscriptionsRepo,
    required BookingSubmitStrategy submitStrategy,
    required BookingCubit booking,
    required BookingPricingCubit pricing,
  }) : _bookingRepo = bookingRepo,
       _subscriptionsRepo = subscriptionsRepo,
       _submitStrategy = submitStrategy,
       _booking = booking,
       _pricing = pricing,
       super(const BookingPaymentState());

  void _emitFailure(String message, {PaymentPhase? paymentPhase}) {
    emit(
      state.copyWith(
        status: BookingStatus.failure,
        errorMessage: message,
        paymentPhase: paymentPhase,
      ),
    );
  }

  BookingSubmission get _submission {
    final selection = _booking.state;
    final pricing = _pricing.state;
    return BookingSubmission(
      selectedService: selection.selectedService,
      selectedAddons: selection.selectedAddons,
      selectedCar: selection.selectedCar,
      selectedAddress: selection.selectedAddress,
      selectedSlotStart: selection.selectedSlotStart,
      selectedPackageService: selection.selectedPackageService,
      bikerNotes: selection.bikerNotes,
      specialNoteText: selection.specialNoteText,
      paymentMethod: selection.paymentMethod,
      quote: pricing.quote,
      appliedOfferId: pricing.appliedOfferId,
      holdToken: state.paymentInit?.holdToken,
      subscriptionId: selection.subscriptionId,
      washId: selection.washId,
      giftCode: selection.giftCode,
    );
  }

  Future<void> submitBooking() async {
    emit(state.copyWith(status: BookingStatus.loading));
    // Delegate to the strategy
    final result = await _submitStrategy.submit(
      repo: _bookingRepo,
      submission: _submission,
    );

    result.fold((failure) => _emitFailure(failure.message), (bookingResponse) {
      _pricing.forgetOffer();
      emit(
        state.copyWith(
          status: BookingStatus.success,
          createdBooking: bookingResponse,
        ),
      );
    });
  }

  Future<PaymentInitModel?> initiatePayment({int? pointsToApply}) async {
    final quoteId = _pricing.state.quote?.quoteId;
    if (quoteId == null) {
      return _declinePayment(LocaleKeys.bookings_missing_quote.tr());
    }

    final selection = _booking.state;
    final slotStart = selection.selectedSlotStart;
    if (slotStart == null) {
      return _declinePayment(LocaleKeys.bookings_missing_slot.tr());
    }

    final car = selection.selectedCar;
    if (car == null) {
      return _declinePayment(LocaleKeys.bookings_missing_vehicle.tr());
    }

    _emitPaymentStarted();
    final result = await _bookingRepo.bookingPaymentInit(
      quoteId: quoteId,
      // Same wire builder ServiceBookingRequestModel.toJson uses, so
      // payment-init and create can never disagree about the slot.
      scheduledAt: toWireDateTime(slotStart),
      vehicles: [_vehiclePayload(car)],
      attemptNonce: const Uuid().v4(),
      pointsToApply: pointsToApply,
    );

    return _settlePaymentInit(result);
  }

  Future<PaymentInitModel?> initiateWashAddonPayment() async {
    final selection = _booking.state;
    final subscriptionId = selection.subscriptionId;
    final washId = selection.washId;
    if (subscriptionId == null || washId == null) {
      return _declinePayment(LocaleKeys.bookings_missing_wash_context.tr());
    }

    final scheduleBody = washScheduleBody(
      vehicleId: selection.selectedCar?.id,
      addOnIds: selection.selectedAddonIds,
    );

    _emitPaymentStarted();
    final result = await _subscriptionsRepo.washAddonPaymentInit(
      subscriptionId: subscriptionId,
      washId: washId,
      scheduleBody: scheduleBody,
      attemptNonce: const Uuid().v4(),
    );

    return _settlePaymentInit(result);
  }

  /// A saved car is sent by id, anything else in full.
  Map<String, dynamic> _vehiclePayload(MyCarModel car) {
    if (car.id.isNotEmpty) return {'savedVehicleId': car.id};

    return {
      'plateText': car.plateNumber,
      if (car.carMake?.vehicleMakeName.nameEn != null)
        'vehicleMake': car.carMake!.vehicleMakeName.nameEn,
      if (car.carModel?.vehicleModelName.nameEn != null)
        'vehicleModel': car.carModel!.vehicleModelName.nameEn,
      'vehicleColor': car.color,
      'vehicleYear': car.modelYear,
    };
  }

  PaymentInitModel? _declinePayment(String message) {
    _emitFailure(message, paymentPhase: PaymentPhase.declined);
    return null;
  }

  void _emitPaymentStarted() {
    emit(
      state.copyWith(
        paymentPhase: PaymentPhase.initiated,
        status: BookingStatus.loading,
      ),
    );
  }

  PaymentInitModel? _settlePaymentInit(
    Either<Failure, PaymentInitModel> result,
  ) {
    return result.fold((failure) => _declinePayment(failure.message), (init) {
      emit(
        state.copyWith(
          status: BookingStatus.initial,
          paymentPhase: PaymentPhase.none,
          paymentInit: init,
        ),
      );
      return init;
    });
  }

  /// The user dismissed the SDK sheet without paying.
  void onPaymentCancelled() {
    emit(state.copyWith(paymentPhase: PaymentPhase.cancelled));
  }

  Future<void> completeBookingAfterPayment(String moyasarPaymentId) async {
    emit(
      state.copyWith(
        paymentPhase: PaymentPhase.paidCreating,
        status: BookingStatus.loading,
      ),
    );

    // The customer has paid, so a flow that cannot carry the payment must end
    // in the unconfirmed alert rather than create a booking without it.
    final strategy = _submitStrategy;
    if (strategy is! PaidBookingSubmitStrategy) {
      _emitFailure(
        LocaleKeys.snackbar_default_error.tr(),
        paymentPhase: PaymentPhase.createUnconfirmed,
      );
      return;
    }

    final result = await strategy.submitPaid(
      repo: _bookingRepo,
      submission: _submission,
      moyasarPaymentId: moyasarPaymentId,
    );

    result.fold(
      (failure) => _emitFailure(
        failure.message,
        paymentPhase: PaymentPhase.createUnconfirmed,
      ),
      (bookingResponse) {
        _pricing.forgetOffer();
        emit(
          state.copyWith(
            status: BookingStatus.success,
            paymentPhase: PaymentPhase.none,
            createdBooking: bookingResponse,
            clearPaymentInit: true,
          ),
        );
      },
    );
  }
}
