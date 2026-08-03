import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/features/booking/data/models/payment_init_model.dart';

abstract class PayingTipsState {}

class PayingTipsInitial extends PayingTipsState {}

class PayingTipsLoading extends PayingTipsState {}

class PayingTipsInitSuccess extends PayingTipsState {
  final PaymentInitModel paymentInit;
  PayingTipsInitSuccess(this.paymentInit);
}

class PayingTipsSuccess extends PayingTipsState {
  final BookingResponseModel booking;
  PayingTipsSuccess(this.booking);
}

class PayingTipsFailure extends PayingTipsState {
  final String message;
  PayingTipsFailure(this.message);
}
