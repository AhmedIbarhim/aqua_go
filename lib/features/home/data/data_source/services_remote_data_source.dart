import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class ServicesRemoteDataSource {
  final APIClient _apiClient;

  ServicesRemoteDataSource(this._apiClient);

  Future<Either<Failure, Response>> getServices() {
    return _apiClient.get(Endpoints.services);
  }
}
