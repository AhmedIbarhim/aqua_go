import 'package:aqua_go/core/helpers/fetch_user_data_helper.dart';
import 'package:aqua_go/core/helpers/idempotency_key_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
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

  Future<Either<Failure, SubscriptionResponseModel>> createSubscription(
    SubscriptionRequestModel subscriptionRequest,
  ) async {
    final cleanNonce =
        subscriptionRequest.nonce ?? DateTime.now().millisecondsSinceEpoch.toString();

    final body = subscriptionRequest.toJson();
    final idempotencyKey = IdempotencyKeyHelper.generate(
      prefix: 'subscription-subscribe',
      userId: FetchUserData.getUserId() ?? '',
      requestId: subscriptionRequest.packageId,
      index: cleanNonce,
    );

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
