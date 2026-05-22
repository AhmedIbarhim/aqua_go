import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';

class NotificationsRemoteDataSource {
  final APIClient _apiClient;

  NotificationsRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> getNotifications({
    int limit = 20,
    String? cursor,
    bool unreadOnly = false,
  }) {
    final Map<String, dynamic> queryParameters = {
      'limit': limit,
      'unreadOnly': unreadOnly,
    };
    if (cursor != null && cursor.isNotEmpty) {
      queryParameters['cursor'] = cursor;
    }

    return _apiClient.get(
      Endpoints.notifications,
      queryParameters: queryParameters,
    );
  }

  Future<Either<Failure, dynamic>> readNotification(String id) {
    return _apiClient.post(Endpoints.readNotification(id));
  }

  Future<Either<Failure, dynamic>> readAllNotifications() {
    return _apiClient.post(Endpoints.readAllNotifications);
  }

  Future<Either<Failure, dynamic>> getUnreadCount() {
    return _apiClient.get(Endpoints.unreadNotificationsCount);
  }
}
