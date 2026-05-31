import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class SubscriptionsRemoteDataSource {
  final APIClient _apiClient;

  SubscriptionsRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> getSubscriptions() {
    return _apiClient.get(Endpoints.subscriptions);
  }

  Future<Either<Failure, dynamic>> subscribe(
    Map<String, dynamic> body,
    String idempotencyKey,
  ) {
    return _apiClient.post(
      Endpoints.subscriptions,
      data: body,
      options: Options(
        headers: {
          'Idempotency-Key': idempotencyKey,
        },
      ),
    );
  }

  Future<Either<Failure, dynamic>> cancelSubscription(
    String subscriptionId,
    Map<String, dynamic> body,
    String idempotencyKey,
  ) {
    return _apiClient.post(
      Endpoints.cancelSubscription(subscriptionId),
      data: body,
      options: Options(
        headers: {
          'Idempotency-Key': idempotencyKey,
        },
      ),
    );
  }
}
