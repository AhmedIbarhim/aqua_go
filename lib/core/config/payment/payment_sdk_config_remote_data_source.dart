import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/config/payment/payment_sdk_config_model.dart';
import 'package:dartz/dartz.dart';

/// Fetches the Moyasar publishable key + Apple Pay config from the server.
///
/// Mirrors the data-source pattern of [BookingsRemoteDataSource].
class PaymentSdkConfigRemoteDataSource {
  final APIClient _apiClient;

  PaymentSdkConfigRemoteDataSource(this._apiClient);

  Future<Either<Failure, PaymentSdkConfigModel>> getSdkConfig() {
    return _apiClient.get<PaymentSdkConfigModel>(
      Endpoints.paymentSdkConfig,
      parser: (data) =>
          PaymentSdkConfigModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
