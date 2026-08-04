import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';

class PoliciesRemoteDataSource {
  final APIClient _apiClient;

  PoliciesRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> getPolicy({
    required String type,
    required String locale,
  }) {
    return _apiClient.get(
      Endpoints.policy(type),
      queryParameters: {'locale': locale},
    );
  }
}
