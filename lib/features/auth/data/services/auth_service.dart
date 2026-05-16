import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:dio/dio.dart';

class AuthService {
  final APIClient _apiClient;

  AuthService(this._apiClient);

  Future<Response> login(String phone) async {
    return await _apiClient.post(
      '/auth/login',
      data: {'phone': phone},
    );
  }

  Future<Response> verifyOtp(String phone, String otp) async {
    return await _apiClient.post(
      '/auth/verify-otp',
      data: {
        'phone': phone,
        'otp': otp,
      },
    );
  }
}
