import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AuthService {
  final APIClient _apiClient;

  AuthService(this._apiClient);

  Future<Either<Failure, Response>> login(String formattedPhone) {
    return _apiClient.post(
      Endpoints.customerSendOtp,
      data: {'phone': formattedPhone},
    );
  }

  Future<Either<Failure, Response>> verifyOtp(String otpSessionId, String code) {
    return _apiClient.post(
      Endpoints.customerVerifyOtp,
      data: {'otpSessionId': otpSessionId, 'code': code},
    );
  }

  Future<Either<Failure, Response>> getProfile() {
    return _apiClient.get(Endpoints.customerMe);
  }

  Future<Either<Failure, Response>> updateProfile(Map<String, dynamic> data) {
    return _apiClient.patch(Endpoints.customerMe, data: data);
  }

  Future<Either<Failure, Response>> requestEmailVerify(String email) {
    return _apiClient.post(
      Endpoints.customerEmailVerifyRequest,
      data: {'email': email},
    );
  }

  Future<Either<Failure, Response>> confirmEmailVerify(String otpSessionId, String code) {
    return _apiClient.post(
      Endpoints.customerEmailVerifyConfirm,
      data: {'otpSessionId': otpSessionId, 'code': code},
    );
  }

  Future<Either<Failure, Response>> logout(String refreshToken) {
    return _apiClient.post(
      Endpoints.customerLogout,
      data: {'refreshToken': refreshToken},
    );
  }
}
