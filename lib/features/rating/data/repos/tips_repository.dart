import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/enums/payment_method_enum.dart';
import 'package:aqua_go/core/helpers/fetch_user_data_helper.dart';
import 'package:aqua_go/core/helpers/idempotency_key_helper.dart';
import 'package:aqua_go/features/booking/data/models/payment_init_model.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/features/rating/data/data_sources/tips_remote_data_source.dart';
import 'package:dartz/dartz.dart';

class TipsRepository {
  final TipsRemoteDataSource _remoteDataSource;

  TipsRepository(this._remoteDataSource);

  Future<Either<Failure, PaymentInitModel>> initiateTipPayment({
    required String bookingId,
    required int amountMinor,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      final idempotencyKey = IdempotencyKeyHelper.generate(
        prefix: 'tip-payment-init',
        userId: FetchUserData.getUserId() ?? '',
        requestId: bookingId,
      );

      final result = await _remoteDataSource.initiateTipPayment(
        bookingId: bookingId,
        amountMinor: amountMinor,
        paymentMethod: paymentMethod,
        idempotencyKey: idempotencyKey,
      );
      return result.fold((failure) => Left(failure), (data) {
        if (data != null) {
          try {
            return Right(
              PaymentInitModel.fromJson(data as Map<String, dynamic>),
            );
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to initialize tip payment'));
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, BookingResponseModel>> payTip({
    required String bookingId,
    required int amountMinor,
    required PaymentMethod paymentMethod,
    String? moyasarPaymentId,
  }) async {
    try {
      final idempotencyKey = IdempotencyKeyHelper.generate(
        prefix: 'pay-tip',
        userId: FetchUserData.getUserId() ?? '',
        requestId: bookingId,
      );

      final result = await _remoteDataSource.payTip(
        bookingId: bookingId,
        amountMinor: amountMinor,
        paymentMethod: paymentMethod,
        idempotencyKey: idempotencyKey,
        moyasarPaymentId: moyasarPaymentId,
      );

      return result.fold((failure) => Left(failure), (data) {
        if (data != null) {
          try {
            final booking = BookingResponseModel.fromJson(
              data as Map<String, dynamic>,
            );
            return Right(booking);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to pay tip'));
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
