import 'package:dartz/dartz.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../data/repos/booking_repository.dart';
import '../../presentation/controllers/booking_state.dart';

abstract class BookingSubmitStrategy {
  /// [moyasarPaymentId] is the verified on-device payment id for the
  /// pay-before-create flow; null for reschedule strategies (state-only,
  /// no money moves).
  Future<Either<Failure, BookingResponseModel>> submit({
    required BookingRepository repo,
    required BookingState state,
    String? moyasarPaymentId,
  });
}
