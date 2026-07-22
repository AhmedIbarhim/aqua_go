import 'package:dartz/dartz.dart';

import '../../../../core/config/networking/exceptions/failure.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../data/models/redeem_gift_booking_request_model.dart';
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
    final request = RedeemGiftBookingRequestModel(
      giftCode: state.giftCode ?? '',
      address: state.selectedAddress,
      car: state.selectedCar,
      date: state.selectedDate,
      time: state.selectedTime,
    );

    return repo.redeemGiftBooking(request);
  }
}
