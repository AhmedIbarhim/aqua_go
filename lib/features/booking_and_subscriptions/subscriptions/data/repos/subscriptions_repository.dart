import 'package:aqua_go/core/helpers/fetch_user_data_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import '../models/subscribed_package_model.dart';
import '../data_sources/subscriptions_remote_data_source.dart';

class SubscriptionsRepository {
  final SubscriptionsRemoteDataSource _subscriptionsDataSource;

  SubscriptionsRepository(this._subscriptionsDataSource);

  Future<Either<Failure, List<SubscribedPackageModel>>>
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
                (json) => SubscribedPackageModel.fromJson(
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

  Future<Either<Failure, SubscribedPackageModel>> fetchSubscriptionDetail({
    required String subscriptionId,
  }) async {
    final result = await _subscriptionsDataSource.getSubscriptionDetail(
      subscriptionId,
    );
    return result.fold((failure) => Left(failure), (data) {
      if (data != null) {
        try {
          final subscription = SubscribedPackageModel.fromJson(
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

  Future<Either<Failure, SubscribedPackageModel>> createSubscription({
    required String packageId,
    String? vehicleId,
    String? addressId,
    List<ScheduleEntry>? initialSchedule,
    String? nonce,
  }) async {
    final cleanNonce =
        nonce ?? DateTime.now().millisecondsSinceEpoch.toString();

    List<ScheduleEntry>? finalSchedule = initialSchedule;
    if (finalSchedule == null && vehicleId != null && addressId != null) {
      finalSchedule = [
        ScheduleEntry(
          scheduledAt: DateTime.now().add(const Duration(hours: 2)),
          addressId: addressId,
          vehicleIds: [vehicleId],
        ),
      ];
    }

    final body = {
      'packageId': packageId,
      'idempotencyNonce': cleanNonce,
      if (finalSchedule != null)
        'initialSchedule': finalSchedule.map((e) => e.toJson()).toList(),
    };
    final idempotencyKey =
        'subscription-subscribe:${FetchUserData.getUserId()}:$packageId:$cleanNonce';

    final result = await _subscriptionsDataSource.subscribe(
      body,
      idempotencyKey,
    );
    return result.fold((failure) => Left(failure), (data) {
      if (data != null) {
        try {
          final subscription = SubscribedPackageModel.fromJson(
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

  Future<Either<Failure, SubscribedPackageModel>> cancelActiveSubscription({
    required String subscriptionId,
    required String reasonCode,
    String? note,
  }) async {
    final body = <String, dynamic>{'reasonCode': reasonCode};
    if (note != null) {
      body['note'] = note;
    }
    final idempotencyKey = 'subscription-cancel:$subscriptionId';

    final result = await _subscriptionsDataSource.cancelSubscription(
      subscriptionId,
      body,
      idempotencyKey,
    );
    return result.fold((failure) => Left(failure), (data) {
      if (data != null) {
        try {
          final subscription = SubscribedPackageModel.fromJson(
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
