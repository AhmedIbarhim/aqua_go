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

  /// Pay-before-create step 1 (spec §4.3): validates the package + customer
  /// state and returns {amountMinor, givenId, metadata} for the Moyasar SDK.
  /// No PSP call — the SDK is the purchase surface.
  Future<Either<Failure, dynamic>> subscriptionPaymentInit({
    required String packageId,
    required String customerId,
    required String idempotencyKey,
  }) {
    return _apiClient.post(
      Endpoints.subscriptionsPaymentInit,
      data: {'packageId': packageId},
      options: Options(
        headers: {'Idempotency-Key': idempotencyKey},
      ),
    );
  }

  /// Pay-before-confirm step 1 (spec §4.4 / A2): computes the payable add-on
  /// delta for a subscription wash and returns {amountMinor, givenId, metadata}
  /// for the Moyasar SDK. No PSP call.
  Future<Either<Failure, dynamic>> washAddonPaymentInit({
    required String subscriptionId,
    required String washId,
    required Map<String, dynamic> body,
    required String idempotencyKey,
  }) {
    return _apiClient.post(
      Endpoints.washAddonPaymentInit(subscriptionId, washId),
      data: body,
      options: Options(
        headers: {'Idempotency-Key': idempotencyKey},
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
