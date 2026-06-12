import 'package:dartz/dartz.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../data/models/day_time_model.dart';
import '../../data/repos/booking_repository.dart';
import '../../controllers/booking_state.dart';
import 'booking_submit_strategy.dart';

class PackageRescheduleBookingSubmit implements BookingSubmitStrategy {
  const PackageRescheduleBookingSubmit();

  @override
  Future<Either<Failure, BookingResponseModel>> submit({
    required BookingRepository repo,
    required BookingState state,
  }) async {
    final List<String> vehicleIds = [];
    if (state.selectedCar != null) {
      vehicleIds.add(state.selectedCar!.id);
    }

    String scheduledAt = '';
    if (state.selectedDate != null && state.selectedTime != null) {
      scheduledAt = DayTimeModel(
        date: state.selectedDate!,
        rawTime: state.selectedTime!,
      ).toScheduledAtString();
      scheduledAt = '${scheduledAt}Z';
    }

    final rescheduleData = {
      'newScheduledAt': scheduledAt,
      'addressId': state.selectedAddress?.id,
      'vehicleIds': vehicleIds,
    };

    return repo.rescheduleSubscriptionWash(
      subscriptionId: state.subscriptionId!,
      washId: state.washId!,
      rescheduleData: rescheduleData,
      newScheduledAtIso: scheduledAt,
    );
  }
}
