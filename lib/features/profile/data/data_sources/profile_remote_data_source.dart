import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';

class ProfileRemoteDataSource {
  final APIClient _apiClient;

  ProfileRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> getNotificationPreferences() {
    return _apiClient.get(Endpoints.notificationPreferences);
  }

  Future<Either<Failure, dynamic>> updateNotificationPreferences(
    Map<String, dynamic> data,
  ) {
    return _apiClient.patch(Endpoints.notificationPreferences, data: data);
  }
}
