import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class SubscriptionsRemoteDataSource {
  final APIClient _apiClient;

  SubscriptionsRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> getSubscriptions({
    int? limit,
    String? cursor,
    String? status,
  }) {
    final queryParameters = <String, dynamic>{};
    if (limit != null) queryParameters['limit'] = limit;
    if (cursor != null) queryParameters['cursor'] = cursor;
    if (status != null) queryParameters['status'] = status;

    return _apiClient.get(
      Endpoints.subscriptions,
      queryParameters: queryParameters,
    );
  }

  Future<Either<Failure, dynamic>> getSubscriptionDetail(String subscriptionId) {
    return _apiClient.get(
      Endpoints.subscriptionDetail(subscriptionId),
    );
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
