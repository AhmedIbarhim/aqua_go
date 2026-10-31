import 'package:dartz/dartz.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../data/repos/booking_repository.dart';
import '../booking_submission.dart';

abstract class BookingSubmitStrategy {
  Future<Either<Failure, BookingResponseModel>> submit({
    required BookingRepository repo,
    required BookingSubmission submission,
  });
}

/// A flow whose booking can be tied to a verified card payment. Only these
/// flows may take money: the others have no field to carry the payment on.
abstract class PaidBookingSubmitStrategy implements BookingSubmitStrategy {
  Future<Either<Failure, BookingResponseModel>> submitPaid({
    required BookingRepository repo,
    required BookingSubmission submission,
    required String moyasarPaymentId,
  });
}
