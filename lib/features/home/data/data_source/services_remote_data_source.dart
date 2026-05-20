import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

class ServicesRemoteDataSource {
  final APIClient _apiClient;

  ServicesRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> getServices() {
    return _apiClient.get(Endpoints.services);
  }
}
