import 'package:equatable/equatable.dart';
import '../data/models/booking_response_model.dart';

abstract class MyBookingDetailsState extends Equatable {
  const MyBookingDetailsState();

  @override
  List<Object?> get props => [];
}

class MyBookingDetailsInitial extends MyBookingDetailsState {}

class MyBookingDetailsLoading extends MyBookingDetailsState {}

class MyBookingDetailsSuccess extends MyBookingDetailsState {
  final BookingResponseModel booking;

  const MyBookingDetailsSuccess(this.booking);

  @override
  List<Object?> get props => [booking];
}

class MyBookingDetailsFailure extends MyBookingDetailsState {
  final String errMessage;

  const MyBookingDetailsFailure(this.errMessage);

  @override
  List<Object?> get props => [errMessage];
}
