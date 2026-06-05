import 'package:equatable/equatable.dart';
import '../../data/models/complaint_model.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';

abstract class ComplaintDetailsState extends Equatable {
  const ComplaintDetailsState();

  @override
  List<Object?> get props => [];
}

class ComplaintDetailsInitial extends ComplaintDetailsState {}

class ComplaintDetailsLoading extends ComplaintDetailsState {}

class ComplaintDetailsSuccess extends ComplaintDetailsState {
  final ComplaintModel complaint;
  final BookingResponseModel? booking;

  const ComplaintDetailsSuccess(this.complaint, this.booking);

  @override
  List<Object?> get props => [complaint, booking];
}

class ComplaintDetailsFailure extends ComplaintDetailsState {
  final String errMessage;

  const ComplaintDetailsFailure(this.errMessage);

  @override
  List<Object?> get props => [errMessage];
}
