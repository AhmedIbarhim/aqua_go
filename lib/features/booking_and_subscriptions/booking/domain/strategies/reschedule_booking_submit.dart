import 'package:dartz/dartz.dart';

import '../../../../../core/config/networking/exceptions/failure.dart';
import '../../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../data/models/reschedule_request_model.dart';
import '../../data/repos/booking_repository.dart';
import '../../controllers/booking_state.dart';
import 'booking_submit_strategy.dart';

/// Strategy for rescheduling an existing booking.
/// Only sends newScheduledAt, addressId, and vehicleIds.
class RescheduleBookingSubmit implements BookingSubmitStrategy {
  final String existingBookingId;

  RescheduleBookingSubmit({required this.existingBookingId});

  @override
  Future<Either<Failure, BookingResponseModel>> submit({
    required BookingRepository repo,
    required BookingState state,
  }) async {
    // Build vehicle IDs list from selected car
    final List<String> vehicleIds = [];
    if (state.selectedCar != null) {
      vehicleIds.add(state.selectedCar!.id);
    }

    final rescheduleRequest = RescheduleRequestModel(
      bookingId: existingBookingId,
      date: state.selectedDate!,
      time: state.selectedTime!,
      addressId: state.selectedAddress?.id,
      vehicleIds: vehicleIds,
    );

    return repo.rescheduleBooking(rescheduleRequest);
  }
}
