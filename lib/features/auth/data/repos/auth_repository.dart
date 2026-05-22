import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/local_storage/secure_storage.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/auth/data/models/user_model.dart';
import 'package:aqua_go/features/auth/data/services/auth_service.dart';
import 'package:dartz/dartz.dart';

class AuthRepository {
  final AuthService _authService;

  UserModel? _cachedUser;

  AuthRepository(this._authService);

  Future<Either<Failure, String>> login(String phone) async {
    await SecureStorage.deleteSecuredString(kAccessToken);
    await SecureStorage.deleteSecuredString(kRefreshToken);

    final result = await _authService.login(phone);
    return result.fold((failure) => Left(failure), (data) {
      if (data != null) {
        final otpSessionId = data['otpSessionId'] as String;
        return Right(otpSessionId);
      }
      return const Left(ServerFailure('Login OTP request failed'));
    });
  }

  Future<Either<Failure, UserModel>> verifyOtp({
    required String phone,
    required String otpSessionId,
    required String otp,
  }) async {
    final result = await _authService.verifyOtp(otpSessionId, otp);
    return result.fold((failure) => Left(failure), (data) async {
      if (data != null) {
        final accessToken = data['accessToken'] as String;
        final refreshToken = data['refreshToken'] as String;

        // Persist JWT tokens locally
        await SecureStorage.saveSecuredString(kAccessToken, accessToken);
        await SecureStorage.saveSecuredString(kRefreshToken, refreshToken);

        // Fetch user profile from `/api/customer/me` using the new tokens
        final profileResult = await _authService.getProfile();
        return profileResult.fold((failure) => Left(failure), (
          profileData,
        ) async {
          if (profileData != null) {
            final profileUser = UserModel.fromJson(
              profileData,
            ).copyWith(phone: phone);
            await saveUser(profileUser);
            return Right(profileUser);
          }
          return const Left(
            ServerFailure('Failed to fetch user profile details'),
          );
        });
      }
      return const Left(ServerFailure('Verification failed'));
    });
  }

  Future<Either<Failure, UserModel>> updateProfile(UserModel user) async {
    final name = user.name ?? '';

    final Map<String, dynamic> updateData = {
      'name': name,
      if (user.gender != null) 'gender': user.gender,
      if (user.birthdate != null)
        'birthdate': user.birthdate!.toIso8601String().split(
          'T',
        )[0], // yyyy-MM-dd
    };

    final result = await _authService.updateProfile(updateData);
    return result.fold((failure) => Left(failure), (data) async {
      final profileResult = await _authService.getProfile();
      return profileResult.fold((failure) => Left(failure), (
        profileData,
      ) async {
        if (profileData != null) {
          final updatedUser = UserModel.fromJson(
            profileData,
          ).copyWith(phone: user.phone);
          await saveUser(updatedUser);
          return Right(updatedUser);
        }
        return const Left(
          ServerFailure('Failed to sync updated profile with server'),
        );
      });
    });
  }

  Future<Either<Failure, String>> requestEmailVerify(String email) async {
    final result = await _authService.requestEmailVerify(email);
    return result.fold((failure) => Left(failure), (data) {
      if (data != null) {
        final otpSessionId = data['otpSessionId'] as String;
        return Right(otpSessionId);
      }
      return const Left(ServerFailure('Failed to send email verification'));
    });
  }

  Future<Either<Failure, UserModel>> confirmEmailVerify({
    required String email,
    required String otpSessionId,
    required String otp,
  }) async {
    final result = await _authService.confirmEmailVerify(otpSessionId, otp);
    return result.fold((failure) => Left(failure), (_) async {
      final currentUser = getUser();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(email: email);
        await saveUser(updatedUser);
        return Right(updatedUser);
      }
      return const Left(ServerFailure('User not found'));
    });
  }

  Future<void> saveUser(UserModel user) async {
    _cachedUser = user;
    await CacheClient.setString(kUserData, user.toEncodedJson());
  }

  UserModel? getUser() {
    if (_cachedUser != null) return _cachedUser;
    final userJson = CacheClient.getString(kUserData);
    if (userJson.isNotEmpty) {
      try {
        _cachedUser = UserModel.fromEncodedJson(userJson);
        return _cachedUser;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> logout() async {
    try {
      final refreshToken = await SecureStorage.getSecuredString(kRefreshToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _authService.logout(refreshToken);
      }
    } catch (_) {
      // Silently ignore logout network failures to guarantee clean local state
    } finally {
      _cachedUser = null;
      await SecureStorage.deleteSecuredString(kAccessToken);
      await SecureStorage.deleteSecuredString(kRefreshToken);
      await CacheClient.removeString(kUserData);
    }
  }
}
