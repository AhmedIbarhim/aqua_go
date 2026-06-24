import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class DeviceService {
  final APIClient _apiClient;

  DeviceService(this._apiClient);

  Future<Either<Failure, dynamic>> registerDevice({
    required String fcmToken,
    required String platform,
    required String appVersion,
    required String locale,
    String? deviceModel,
    String? idempotencyKey,
  }) {
    final Map<String, dynamic> data = {
      'fcmToken': fcmToken,
      'platform': platform,
      'appVersion': appVersion,
      'locale': locale,
      if (deviceModel != null) 'deviceModel': deviceModel,
    };

    return _apiClient.post(
      Endpoints.registerDevice,
      data: data,
      options: Options(
        headers: {
          if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
        },
      ),
    );
  }

  Future<Either<Failure, dynamic>> deregisterDevice(String deviceId) {
    return _apiClient.delete(
      Endpoints.deregisterDevice(deviceId),
    );
  }
}
