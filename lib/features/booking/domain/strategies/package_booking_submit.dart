import 'package:dartz/dartz.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../data/models/day_time_model.dart';
import '../../data/repos/booking_repository.dart';
import '../../presentation/controllers/booking_state.dart';
import 'booking_submit_strategy.dart';

class PackageBookingSubmit implements BookingSubmitStrategy {
  const PackageBookingSubmit();

  @override
  Future<Either<Failure, BookingResponseModel>> submit({
    required BookingRepository repo,
    required BookingState state,
  }) async {
    final List<Map<String, dynamic>> addonsJson = [];
    final availableAddons = state.selectedService?.addons ?? [];
    for (final idx in state.selectedServiceIndices) {
      if (idx < availableAddons.length) {
        addonsJson.add({'addonId': availableAddons[idx].id});
      }
    }

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
      // append 'Z' or offset if required, but standard Iso-8601 is expected. Let's make sure it matches the format in Swagger: e.g. "2026-06-12T20:01:09.623Z"
      scheduledAt = '${scheduledAt}Z';
    }

    final scheduleData = {
      'scheduledAt': scheduledAt,
      'addressId': state.selectedAddress?.id,
      'vehicleIds': vehicleIds,
      'addOns': addonsJson,
    };

    return repo.scheduleSubscriptionWash(
      subscriptionId: state.subscriptionId!,
      washId: state.washId!,
      scheduleData: scheduleData,
    );
  }
}
