import 'package:equatable/equatable.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';

abstract class PendingRatingsState extends Equatable {
  const PendingRatingsState();

  @override
  List<Object?> get props => [];
}

class PendingRatingsInitial extends PendingRatingsState {}

class PendingRatingsLoading extends PendingRatingsState {}

/// Emitted with the bookings still awaiting a rating AFTER locally-dismissed
/// ids have been filtered out. [bookings] is most-recent-completion first, so
/// the home popup prompts with `bookings.first`.
class PendingRatingsLoaded extends PendingRatingsState {
  final List<BookingResponseModel> bookings;

  const PendingRatingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class PendingRatingsFailure extends PendingRatingsState {
  final String message;

  const PendingRatingsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
