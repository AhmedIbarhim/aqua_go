import 'dart:io';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/local_storage/secure_storage.dart';
import 'package:aqua_go/core/config/session/session_state.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/auth/data/models/user_model.dart';
import 'package:aqua_go/features/auth/data/services/auth_service.dart';
import 'package:aqua_go/features/auth/data/services/device_token_sync.dart';
import 'package:aqua_go/core/helpers/idempotency_key_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

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
            // Fire-and-forget: register FCM token now that the user is known.
            syncDeviceToken();
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
      if (user.locale != null) 'locale': user.locale,
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

  /// Wipes any stale/expired JWT so a fresh session (including guest mode)
  /// never reuses an invalid token.
  Future<void> clearSession() async {
    _cachedUser = null;
    await SecureStorage.deleteSecuredString(kAccessToken);
    await SecureStorage.deleteSecuredString(kRefreshToken);
    // PH1-024: also purge the persisted cached profile so no prior-user PII
    // residue survives; combined with the token-gate in restoreCachedUser this
    // means a stale blob can never be resurrected into a fresh/guest session.
    await SecureStorage.deleteSecuredString(kUserData);
    currentUser.value = null;
  }

  /// Purges the local session (tokens + cached user) WITHOUT a network call
  /// and WITHOUT touching unrelated prefs (kNotFirstUse, language, theme,
  /// install marker).
  Future<void> purgeLocalSession() async {
    _cachedUser = null;
    await SecureStorage.clearSecuredData();
    await CacheClient.removeString(kUserData);
    currentUser.value = null;
  }

  Future<void> saveUser(UserModel user) async {
    _cachedUser = user;
    currentUser.value = user;
    // PH1-008: the cached UserModel carries PII (name/email/phone/DOB) — persist
    // it in encrypted secure storage, never plaintext SharedPreferences.
    await SecureStorage.saveSecuredString(kUserData, user.toEncodedJson());
  }

  /// Synchronous accessor over the in-memory cache. PH1-008: disk hydration is
  /// no longer done here (secure storage is async) — cold-start restore runs
  /// once via [restoreCachedUser]; all mid-session callers read this cache.
  UserModel? getUser() => _cachedUser;

  /// Cold-start rehydration of the cached user from secure storage. PH1-024:
  /// gated on a valid access token — a stale [kUserData] blob is never
  /// resurrected once the session's tokens are gone (prevents PII residue /
  /// prior-user enumeration). Returns null on any decode failure.
  Future<UserModel?> restoreCachedUser() async {
    if (_cachedUser != null) return _cachedUser;
    final token = await SecureStorage.getSecuredString(kAccessToken);
    if (token == null || token.isEmpty) return null;
    final userJson = await SecureStorage.getSecuredString(kUserData);
    if (userJson == null || userJson.isEmpty) return null;
    try {
      _cachedUser = UserModel.fromEncodedJson(userJson);
      if (currentUser.value == null) currentUser.value = _cachedUser;
      return _cachedUser;
    } catch (_) {
      return null;
    }
  }

  /// Validates the persisted session by fetching `/api/customer/me`. On success
  /// the fresh profile is cached and returned; on failure the caller decides
  /// whether the session is recoverable (offline) or broken (auth/expired).
  Future<Either<Failure, UserModel>> refreshProfile() async {
    final result = await _authService.getProfile();
    return result.fold((failure) => Left(failure), (profileData) async {
      if (profileData == null) {
        return const Left(ServerFailure('Failed to fetch user profile'));
      }
      final fetched = UserModel.fromJson(profileData);
      // `/me` may omit the phone; keep the locally-known one when present.
      final user = (fetched.phone == null || fetched.phone!.isEmpty)
          ? fetched.copyWith(phone: getUser()?.phone)
          : fetched;
      await saveUser(user);
      return Right(user);
    });
  }

  Future<void> logout() async {
    // Deregister FCM token before wiping auth state so the stored device id
    // is still readable during deregistration.
    await deregisterStoredDevice();
    try {
      final refreshToken = await SecureStorage.getSecuredString(kRefreshToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _authService.logout(refreshToken);
      }
    } catch (_) {
      // Silently ignore logout network failures to guarantee clean local state
    } finally {
      // Use the same targeted teardown as purgeLocalSession() so that
      // kNotFirstUse, kLanguage, kThemeMode, and kSessionInstallMarker survive.
      // The install marker must persist across deliberate logouts — it only
      // becomes absent after an OS-driven reinstall (when SharedPrefs is wiped
      // externally), which is the reinstall-detection scenario it was designed for.
      _cachedUser = null;
      await SecureStorage.clearSecuredData();
      await CacheClient.removeString(kUserData);
      await CacheClient.removeString(kIsGuest);
      currentUser.value = null;
    }
  }

  Future<Either<Failure, void>> deleteAccount() async {
    final idempotencyKey = IdempotencyKeyHelper.generate(
      prefix: 'auth-delete-account',
    );
    final result = await _authService.deleteAccount(
      idempotencyKey: idempotencyKey,
    );
    return result.fold((failure) => Left(failure), (_) async {
      // Deregister FCM token before wiping auth state.
      await deregisterStoredDevice();
      // Same targeted teardown as logout() — preserve kNotFirstUse,
      // kLanguage, kThemeMode, kSessionInstallMarker.
      _cachedUser = null;
      await SecureStorage.clearSecuredData();
      await CacheClient.removeString(kUserData);
      await CacheClient.removeString(kIsGuest);
      currentUser.value = null;
      return Right(null);
    });
  }

  Future<Either<Failure, UserModel>> uploadProfileImage(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return const Left(ServerFailure('File does not exist'));
    }
    final int sizeBytes = await file.length();
    final String contentType = _getFileContentType(filePath);

    final presignResult = await _authService.getProfileImagePresignedUrl(
      contentType,
    );
    return presignResult.fold((failure) => Left(failure), (data) async {
      if (data == null) {
        return const Left(ServerFailure('Failed to get presigned URL'));
      }
      final String? uploadUrl = data['url'];
      if (uploadUrl == null || uploadUrl.isEmpty) {
        return const Left(ServerFailure('Presigned URL is empty'));
      }

      try {
        final dio = Dio();
        final bytes = await file.readAsBytes();
        final uploadResponse = await dio.put(
          uploadUrl,
          data: Stream.fromIterable([bytes]),
          options: Options(
            headers: {
              Headers.contentTypeHeader: contentType,
              Headers.contentLengthHeader: sizeBytes,
            },
          ),
        );

        if (uploadResponse.statusCode != 200 &&
            uploadResponse.statusCode != 201 &&
            uploadResponse.statusCode != 204) {
          return const Left(
            ServerFailure('Failed to upload image file to storage'),
          );
        }
      } catch (e) {
        return Left(ServerFailure('Failed to upload image binary: $e'));
      }

      final String idempotencyKey = IdempotencyKeyHelper.generate(
        prefix: 'profile-image-confirm',
      );
      final confirmResult = await _authService.confirmProfileImage(
        contentType: contentType,
        sizeBytes: sizeBytes,
        idempotencyKey: idempotencyKey,
      );

      return confirmResult.fold((failure) => Left(failure), (_) async {
        final profileResult = await _authService.getProfile();
        return profileResult.fold((failure) => Left(failure), (
          profileData,
        ) async {
          if (profileData != null) {
            final currentUser = getUser();
            final updatedUser = UserModel.fromJson(
              profileData,
            ).copyWith(phone: currentUser?.phone);
            await saveUser(updatedUser);
            return Right(updatedUser);
          }
          return const Left(
            ServerFailure('Failed to fetch updated profile details'),
          );
        });
      });
    });
  }

  String _getFileContentType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    if (extension == 'jpg' || extension == 'jpeg') return 'image/jpeg';
    if (extension == 'png') return 'image/png';
    if (extension == 'webp') return 'image/webp';
    if (extension == 'gif') return 'image/gif';
    return 'application/octet-stream';
  }
}
