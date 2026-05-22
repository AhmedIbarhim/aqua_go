import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/notifications/data/data_sources/notifications_remote_data_source.dart';
import 'package:aqua_go/features/notifications/data/models/notification_model.dart';
import 'package:dartz/dartz.dart';

class NotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;

  NotificationsRepository(this._remoteDataSource);

  Future<Either<Failure, NotificationsPageModel>> getNotifications({
    int limit = 20,
    String? cursor,
    bool unreadOnly = false,
  }) async {
    final result = await _remoteDataSource.getNotifications(
      limit: limit,
      cursor: cursor,
      unreadOnly: unreadOnly,
    );
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final page = NotificationsPageModel.fromJson(data as Map<String, dynamic>);
            return Right(page);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to load notifications'));
      },
    );
  }

  Future<Either<Failure, void>> readNotification(String id) async {
    final result = await _remoteDataSource.readNotification(id);
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<Failure, void>> readAllNotifications() async {
    final result = await _remoteDataSource.readAllNotifications();
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<Failure, int>> getUnreadCount() async {
    final result = await _remoteDataSource.getUnreadCount();
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final count = (data as Map<String, dynamic>)['count'] as int? ?? 0;
            return Right(count);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to parse unread count'));
      },
    );
  }
}
