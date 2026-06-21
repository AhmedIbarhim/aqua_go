import 'package:dartz/dartz.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../data/models/package_reschedule_request_model.dart';
import '../../data/repos/booking_repository.dart';
import '../../presentation/controllers/booking_state.dart';
import 'booking_submit_strategy.dart';

class PackageRescheduleBookingSubmit implements BookingSubmitStrategy {
  const PackageRescheduleBookingSubmit();

  @override
  Future<Either<Failure, BookingResponseModel>> submit({
    required BookingRepository repo,
    required BookingState state,
    String? moyasarPaymentId,
  }) async {
    final List<String> vehicleIds = [];
    if (state.selectedCar != null) {
      vehicleIds.add(state.selectedCar!.id);
    }

    final rescheduleRequest = PackageRescheduleRequestModel(
      date: state.selectedDate!,
      time: state.selectedTime!,
      address: state.selectedAddress,
      vehicleIds: vehicleIds,
    );

    return repo.rescheduleSubscriptionWash(
      subscriptionId: state.subscriptionId!,
      washId: state.washId!,
      request: rescheduleRequest,
    );
  }
}
