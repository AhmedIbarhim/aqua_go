import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/auth/data/models/registered_device_model.dart';
import 'package:aqua_go/features/auth/data/services/device_service.dart';
import 'package:dartz/dartz.dart';

class DeviceRepository {
  final DeviceService _deviceService;

  DeviceRepository(this._deviceService);

  Future<Either<Failure, RegisteredDeviceModel>> registerDevice({
    required String fcmToken,
    required String platform,
    required String appVersion,
    required String locale,
    String? deviceModel,
    String? idempotencyKey,
  }) async {
    final result = await _deviceService.registerDevice(
      fcmToken: fcmToken,
      platform: platform,
      appVersion: appVersion,
      locale: locale,
      deviceModel: deviceModel,
      idempotencyKey: idempotencyKey,
    );
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final registeredDevice = RegisteredDeviceModel.fromJson(
              data as Map<String, dynamic>,
            );
            return Right(registeredDevice);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to register device'));
      },
    );
  }

  Future<Either<Failure, void>> deregisterDevice(String deviceId) async {
    final result = await _deviceService.deregisterDevice(deviceId);
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }
}
