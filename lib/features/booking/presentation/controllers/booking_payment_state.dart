import 'package:equatable/equatable.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../data/models/payment_init_model.dart';
import 'booking_state.dart';

/// The on-device pay-before-create phase (spec §10). `none` is the resting
/// state outside a payment attempt.
enum PaymentPhase {
  none,

  /// payment-init in flight (re-validate quote + soft-hold slot).
  initiated,

  /// the verified-paid payment is being sent to create the row.
  verifying,

  /// server is creating the booking after a verified payment.
  paidCreating,

  /// card declined / payment failed — retry in place.
  declined,

  /// user dismissed the SDK sheet.
  cancelled,

  createUnconfirmed,
}

class BookingPaymentState extends Equatable {
  final BookingStatus status;
  final String? errorMessage;

  /// Current pay-before-create phase.
  final PaymentPhase paymentPhase;

  /// The payment-init result driving the SDK purchase (null when not paying).
  final PaymentInitModel? paymentInit;
  final BookingResponseModel? createdBooking;

  const BookingPaymentState({
    this.status = BookingStatus.initial,
    this.errorMessage,
    this.paymentPhase = PaymentPhase.none,
    this.paymentInit,
    this.createdBooking,
  });

  BookingPaymentState copyWith({
    BookingStatus? status,
    String? errorMessage,
    PaymentPhase? paymentPhase,
    PaymentInitModel? paymentInit,
    BookingResponseModel? createdBooking,
    bool clearPaymentInit = false,
  }) {
    return BookingPaymentState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      paymentPhase: paymentPhase ?? this.paymentPhase,
      paymentInit: clearPaymentInit ? null : (paymentInit ?? this.paymentInit),
      createdBooking: createdBooking ?? this.createdBooking,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    paymentPhase,
    paymentInit,
    createdBooking,
  ];
}
