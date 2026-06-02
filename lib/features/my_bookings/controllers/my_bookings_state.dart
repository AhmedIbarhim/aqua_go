import 'package:equatable/equatable.dart';
import '../data/models/booking_response_model/booking_response_model.dart';

abstract class MyBookingsState extends Equatable {
  const MyBookingsState();

  @override
  List<Object?> get props => [];
}

class MyBookingsInitial extends MyBookingsState {}

class MyBookingsLoading extends MyBookingsState {}

class MyBookingsSuccess extends MyBookingsState {
  final List<BookingResponseModel> bookings;
  final String? nextCursor;
  final bool hasReachedMax;

  const MyBookingsSuccess({
    required this.bookings,
    this.nextCursor,
    required this.hasReachedMax,
  });

  MyBookingsSuccess copyWith({
    List<BookingResponseModel>? bookings,
    String? nextCursor,
    bool? hasReachedMax,
  }) {
    return MyBookingsSuccess(
      bookings: bookings ?? this.bookings,
      nextCursor: nextCursor ?? this.nextCursor,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [bookings, nextCursor, hasReachedMax];
}

class MyBookingsFailure extends MyBookingsState {
  final String errMessage;

  const MyBookingsFailure(this.errMessage);

  @override
  List<Object?> get props => [errMessage];
}
