import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class CarsRemoteDataSource {
  final APIClient _apiClient;

  CarsRemoteDataSource(this._apiClient);

  Future<Either<Failure, Response>> getVehicles() {
    return _apiClient.get(Endpoints.myVehicles);
  }

  Future<Either<Failure, Response>> addVehicle(Map<String, dynamic> data) {
    return _apiClient.post(Endpoints.myVehicles, data: data);
  }

  Future<Either<Failure, Response>> updateVehicle(
    String vehicleId,
    Map<String, dynamic> data,
  ) {
    return _apiClient.patch(Endpoints.myVehicle(vehicleId), data: data);
  }

  Future<Either<Failure, Response>> deleteVehicle(String vehicleId) {
    return _apiClient.delete(Endpoints.myVehicle(vehicleId));
  }

  Future<Either<Failure, Response>> getVehicleMakes() {
    return _apiClient.get(Endpoints.vehicleBrands);
  }

  Future<Either<Failure, Response>> getVehicleModels(String makeId) {
    return _apiClient.get(Endpoints.vehicleModels(makeId));
  }
}
