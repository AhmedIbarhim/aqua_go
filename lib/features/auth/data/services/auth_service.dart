import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AuthService {
  final APIClient _apiClient;

  AuthService(this._apiClient);

  Future<Either<Failure, dynamic>> login(String formattedPhone) {
    return _apiClient.post(Endpoints.sendOtp, data: {'phone': formattedPhone});
  }

  Future<Either<Failure, dynamic>> verifyOtp(String otpSessionId, String code) {
    return _apiClient.post(
      Endpoints.verifyOtp,
      data: {'otpSessionId': otpSessionId, 'code': code},
    );
  }

  Future<Either<Failure, dynamic>> getProfile() {
    return _apiClient.get(Endpoints.customerMe);
  }

  Future<Either<Failure, dynamic>> updateProfile(Map<String, dynamic> data) {
    return _apiClient.patch(Endpoints.customerMe, data: data);
  }

  Future<Either<Failure, dynamic>> requestEmailVerify(String email) {
    return _apiClient.post(Endpoints.verifyRequest, data: {'email': email});
  }

  Future<Either<Failure, dynamic>> confirmEmailVerify(
    String otpSessionId,
    String code,
  ) {
    return _apiClient.post(
      Endpoints.emailVerifyConfirm,
      data: {'otpSessionId': otpSessionId, 'code': code},
    );
  }

  Future<Either<Failure, dynamic>> logout(String refreshToken) {
    return _apiClient.post(
      Endpoints.logout,
      data: {'refreshToken': refreshToken},
    );
  }

  /// Calls the refresh-token endpoint directly on the raw Dio instance,
  /// bypassing the auth interceptor to avoid circular retry loops.
  Future<Response> refreshAccessToken(String refreshToken) {
    return _apiClient.dio.post(
      Endpoints.refreshToken,
      data: {'refreshToken': refreshToken},
    );
  }
}
