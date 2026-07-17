import 'package:dartz/dartz.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../data/models/day_time_model.dart';
import '../../data/repos/booking_repository.dart';
import '../../presentation/controllers/booking_state.dart';
import 'booking_submit_strategy.dart';

class RedeemGiftBookingSubmit implements BookingSubmitStrategy {
  const RedeemGiftBookingSubmit();

  @override
  Future<Either<Failure, BookingResponseModel>> submit({
    required BookingRepository repo,
    required BookingState state,
    String? moyasarPaymentId,
  }) async {
    final addr = state.selectedAddress;
    final car = state.selectedCar;

    final isSavedAddress =
        addr?.id != null &&
        addr?.id != 'current_gps' &&
        addr?.id != 'custom_map';

    String scheduledAt = '';
    if (state.selectedDate != null && state.selectedTime != null) {
      scheduledAt = DayTimeModel(
        date: state.selectedDate!,
        rawTime: state.selectedTime!,
      ).toScheduledAtString();
    }

    final data = {
      'giftCode': state.giftCode ?? '',
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
