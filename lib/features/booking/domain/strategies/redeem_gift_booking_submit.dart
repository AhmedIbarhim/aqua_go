import 'package:dartz/dartz.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../../../core/utils/saudi_wire_format.dart';
import '../../data/repos/booking_repository.dart';
import '../booking_submission.dart';
import 'booking_submit_strategy.dart';

class RedeemGiftBookingSubmit implements BookingSubmitStrategy {
  const RedeemGiftBookingSubmit();

  @override
  Future<Either<Failure, BookingResponseModel>> submit({
    required BookingRepository repo,
    required BookingSubmission submission,
  }) async {
    final addr = submission.selectedAddress;
    final car = submission.selectedCar;

    final isSavedAddress =
        addr?.id != null &&
        addr?.id != 'current_gps' &&
        addr?.id != 'custom_map';

    final slotStart = submission.selectedSlotStart;
    final String scheduledAt = slotStart != null
        ? toWireDateTime(slotStart)
        : '';

    final data = {
      'giftCode': submission.giftCode ?? '',
      'addressLabel': addr?.label ?? '',
      'lat': addr?.lat ?? 0.0,
      'lng': addr?.lng ?? 0.0,
      'addressArrivalNotes': addr?.arrivalNotes ?? addr?.details ?? '',
      'plateText': car?.plateNumber ?? '',
      'vehicleMake': car?.make ?? '',
      'vehicleModel': car?.model ?? '',
      'vehicleColor': car?.color ?? '',
      'vehicleYear': car?.modelYear ?? 2022,
      'type': 'SCHEDULED',
      'scheduledAt': scheduledAt,
      if (isSavedAddress) 'savedAddressId': addr?.id,
      if (car?.id != null && car!.id.isNotEmpty) 'savedVehicleId': car.id,
    };

    return repo.redeemGiftBooking(data);
  }
}
