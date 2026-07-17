import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/enums/payment_method_enum.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class TipsRemoteDataSource {
  final APIClient _apiClient;

  TipsRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> initiateTipPayment({
    required String bookingId,
    required int amountMinor,
    required PaymentMethod paymentMethod,
  }) {
    return _apiClient.post(
      Endpoints.tipBookingPaymentInit(bookingId),
      data: {'amountMinor': amountMinor, 'paymentMethod': paymentMethod.name},
    );
  }

  Future<Either<Failure, dynamic>> payTip({
    required String bookingId,
    required int amountMinor,
    required PaymentMethod paymentMethod,
    required String idempotencyKey,
    String? moyasarPaymentId,
  }) {
    return _apiClient.post(
      Endpoints.tipBooking(bookingId),
      data: {
        'amountMinor': amountMinor,
        'paymentMethod': paymentMethod.name,
        'moyasarPaymentId': ?moyasarPaymentId,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
  }
}
