import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:aqua_go/features/profile/data/models/notification_preferences_model.dart';
import 'package:dartz/dartz.dart';

class ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepository(this._remoteDataSource);

  Future<Either<Failure, NotificationPreferencesModel>> getNotificationPreferences() async {
    final result = await _remoteDataSource.getNotificationPreferences();
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final preferences = NotificationPreferencesModel.fromJson(
              data as Map<String, dynamic>,
            );
            return Right(preferences);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to load notification preferences'));
      },
    );
  }

  Future<Either<Failure, NotificationPreferencesModel>> updateNotificationPreferences(
    NotificationPreferencesModel preferences,
  ) async {
    final Map<String, dynamic> data = preferences.toPatchJson();
    final result = await _remoteDataSource.updateNotificationPreferences(data);
    return result.fold(
      (failure) => Left(failure),
      (responseData) {
        if (responseData != null) {
          try {
            final updatedPreferences = NotificationPreferencesModel.fromJson(
              responseData as Map<String, dynamic>,
            );
            return Right(updatedPreferences);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to update notification preferences'));
      },
    );
  }
}
