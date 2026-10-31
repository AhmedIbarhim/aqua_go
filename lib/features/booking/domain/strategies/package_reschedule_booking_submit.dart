import 'package:dartz/dartz.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../data/models/package_reschedule_request_model.dart';
import '../../data/repos/booking_repository.dart';
import '../booking_submission.dart';
import 'booking_submit_strategy.dart';

class PackageRescheduleBookingSubmit implements BookingSubmitStrategy {
  const PackageRescheduleBookingSubmit();

  @override
  Future<Either<Failure, BookingResponseModel>> submit({
    required BookingRepository repo,
    required BookingSubmission submission,
  }) async {
    final List<String> vehicleIds = [];
    if (submission.selectedCar != null) {
      vehicleIds.add(submission.selectedCar!.id);
    }

    final rescheduleRequest = PackageRescheduleRequestModel(
      slotStart: submission.selectedSlotStart!,
      address: submission.selectedAddress,
      vehicleIds: vehicleIds,
    );

    return repo.rescheduleSubscriptionWash(
      subscriptionId: submission.subscriptionId!,
      washId: submission.washId!,
      request: rescheduleRequest,
    );
  }
}
