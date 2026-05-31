import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';

class PackagesRemoteDataSource {
  final APIClient _apiClient;

  PackagesRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> getPackages() {
    return _apiClient.get(Endpoints.packages);
  }
}
