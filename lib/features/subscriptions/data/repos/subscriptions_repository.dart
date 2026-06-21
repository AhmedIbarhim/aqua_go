import 'package:aqua_go/core/helpers/idempotency_key_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/booking/data/models/payment_init_model.dart';
import '../models/subscription_response_model/subscription_response_model.dart';
import '../models/subscription_request_model.dart';
import '../data_sources/subscriptions_remote_data_source.dart';

class SubscriptionsRepository {
  final SubscriptionsRemoteDataSource _subscriptionsDataSource;

  SubscriptionsRepository(this._subscriptionsDataSource);

  Future<Either<Failure, List<SubscriptionResponseModel>>>
  fetchActiveSubscriptions({int? limit, String? cursor, String? status}) async {
    final result = await _subscriptionsDataSource.getSubscriptions(
      limit: limit,
      cursor: cursor,
      status: status,
    );
    return result.fold((failure) => Left(failure), (data) {
      if (data != null) {
        try {
          List<dynamic> list = [];
          if (data is Map<String, dynamic>) {
            list = data['items'] as List<dynamic>? ?? [];
          } else if (data is List<dynamic>) {
            list = data;
          }
          final parsed = list
              .map(
                (json) => SubscriptionResponseModel.fromJson(
                  json as Map<String, dynamic>,
                ),
              )
              .toList();
          return Right(parsed);
        } catch (e) {
          return Left(ServerFailure('Parsing error: $e'));
        }
      }
      return const Left(ServerFailure('Failed to load subscriptions'));
    });
  }

  Future<Either<Failure, SubscriptionResponseModel>> fetchSubscriptionDetail({
    required String subscriptionId,
  }) async {
    final result = await _subscriptionsDataSource.getSubscriptionDetail(
      subscriptionId,
    );
    return result.fold((failure) => Left(failure), (data) {
      if (data != null) {
        try {
          final subscription = SubscriptionResponseModel.fromJson(
            data as Map<String, dynamic>,
          );
          return Right(subscription);
        } catch (e) {
          return Left(ServerFailure('Parsing error: $e'));
        }
      }
      return const Left(ServerFailure('Failed to load subscription details'));
    });
  }

  /// Pay-before-create step 1 for subscriptions (spec §4.3): re-validates the
  /// package + customer and returns the SDK payload. No PSP call.
  /// Idempotency key: `subscription-payment-init:{customerId}:{packageId}`.
  Future<Either<Failure, PaymentInitModel>> subscriptionPaymentInit({
    required String packageId,
    required String customerId,
  }) async {
    final idempotencyKey = 'subscription-payment-init:$customerId:$packageId';
    final result = await _subscriptionsDataSource.subscriptionPaymentInit(
      packageId: packageId,
      customerId: customerId,
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
      return const Left(ServerFailure('Failed to initialize subscription payment'));
    });
  }

  /// Pay-before-confirm step 1 for wash add-ons (spec §4.4 / A2): computes the
  /// payable add-on delta and returns the SDK payload. No PSP call.
  /// Idempotency key: `wash-addon-payment-init:{washId}`.
  Future<Either<Failure, PaymentInitModel>> washAddonPaymentInit({
    required String subscriptionId,
    required String washId,
    required Map<String, dynamic> scheduleBody,
  }) async {
    final idempotencyKey = 'wash-addon-payment-init:$washId';
    final result = await _subscriptionsDataSource.washAddonPaymentInit(
      subscriptionId: subscriptionId,
      washId: washId,
      body: scheduleBody,
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
      return const Left(ServerFailure('Failed to initialize wash add-on payment'));
    });
  }

  Future<Either<Failure, SubscriptionResponseModel>> createSubscription(
    SubscriptionRequestModel subscriptionRequest,
  ) async {
    final body = subscriptionRequest.toJson();
    // Deterministic pay-before-create key: a retried create against the same
    // verified Moyasar payment replays the same subscription (spec §9.5).
    final idempotencyKey =
        'subscription-create:${subscriptionRequest.moyasarPaymentId}';

    final result = await _subscriptionsDataSource.subscribe(
      body,
      idempotencyKey,
    );
    return result.fold((failure) => Left(failure), (data) {
      if (data != null) {
        try {
          final subscription = SubscriptionResponseModel.fromJson(
            data as Map<String, dynamic>,
          );
          return Right(subscription);
        } catch (e) {
          return Left(ServerFailure('Parsing error: $e'));
        }
      }
      return const Left(ServerFailure('Failed to create subscription'));
    });
  }

  Future<Either<Failure, SubscriptionResponseModel>> cancelActiveSubscription({
    required String subscriptionId,
    required String reasonCode,
    String? note,
  }) async {
    final body = <String, dynamic>{'reasonCode': reasonCode};
    if (note != null) {
      body['note'] = note;
    }
    final idempotencyKey = IdempotencyKeyHelper.generate(
      prefix: 'subscription-cancel',
      requestId: subscriptionId,
    );

    final result = await _subscriptionsDataSource.cancelSubscription(
      subscriptionId,
      body,
      idempotencyKey,
    );
    return result.fold((failure) => Left(failure), (data) {
      if (data != null) {
        try {
          final subscription = SubscriptionResponseModel.fromJson(
            data as Map<String, dynamic>,
          );
          return Right(subscription);
        } catch (e) {
          return Left(ServerFailure('Parsing error: $e'));
        }
      }
      return const Left(ServerFailure('Failed to cancel subscription'));
    });
  }
}
