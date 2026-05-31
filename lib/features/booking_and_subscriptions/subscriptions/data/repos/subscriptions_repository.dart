import 'package:dartz/dartz.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import '../models/subscribed_package_model.dart';
import '../data_sources/subscriptions_remote_data_source.dart';

class SubscriptionsRepository {
  final SubscriptionsRemoteDataSource _subscriptionsDataSource;

  SubscriptionsRepository(this._subscriptionsDataSource);

  Future<Either<Failure, List<SubscribedPackageModel>>> fetchActiveSubscriptions() async {
    final result = await _subscriptionsDataSource.getSubscriptions();
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            List<dynamic> list = [];
            if (data is Map<String, dynamic>) {
              list = data['items'] as List<dynamic>? ?? [];
            } else if (data is List<dynamic>) {
              list = data;
            }
            final parsed = list
                .map((json) => SubscribedPackageModel.fromJson(json as Map<String, dynamic>))
                .toList();
            return Right(parsed);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to load subscriptions'));
      },
    );
  }

  Future<Either<Failure, SubscribedPackageModel>> createSubscription({
    required String packageId,
    required String vehicleId,
    required String addressId,
    String? nonce,
  }) async {
    final cleanNonce = nonce ?? DateTime.now().millisecondsSinceEpoch.toString();
    final body = {
      'packageId': packageId,
      'vehicleId': vehicleId,
      'addressId': addressId,
      'initialSchedule': const [], // default scheduling later
      'idempotencyNonce': cleanNonce,
    };
    final idempotencyKey = 'subscription-subscribe:$packageId-$cleanNonce';

    final result = await _subscriptionsDataSource.subscribe(body, idempotencyKey);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final subscription = SubscribedPackageModel.fromJson(data as Map<String, dynamic>);
            return Right(subscription);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to create subscription'));
      },
    );
  }

  Future<Either<Failure, SubscribedPackageModel>> cancelActiveSubscription({
    required String subscriptionId,
    required String reasonCode,
    String? note,
  }) async {
    final body = <String, dynamic>{
      'reasonCode': reasonCode,
    };
    if (note != null) {
      body['note'] = note;
    }
    final idempotencyKey = 'subscription-cancel:$subscriptionId';

    final result = await _subscriptionsDataSource.cancelSubscription(
      subscriptionId,
      body,
      idempotencyKey,
    );
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final subscription = SubscribedPackageModel.fromJson(data as Map<String, dynamic>);
            return Right(subscription);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to cancel subscription'));
      },
    );
  }
}
