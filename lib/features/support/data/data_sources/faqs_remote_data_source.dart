import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';

class FaqsRemoteDataSource {
  final APIClient _apiClient;

  FaqsRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> getFaqs() {
    return _apiClient.get(Endpoints.faqs);
  }
}
