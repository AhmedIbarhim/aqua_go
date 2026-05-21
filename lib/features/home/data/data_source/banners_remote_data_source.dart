import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';

class BannersRemoteDataSource {
  final APIClient _apiClient;

  BannersRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> getBanners() {
    return _apiClient.get(Endpoints.banners);
  }
}
