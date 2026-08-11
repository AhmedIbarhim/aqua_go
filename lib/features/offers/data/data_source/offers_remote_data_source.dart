import 'package:aqua_go/core/config/networking/anonymous_session_policy.dart';
import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class OffersRemoteDataSource {
  final APIClient _apiClient;

  OffersRemoteDataSource(this._apiClient);

  Options get _anonymousFriendly =>
      Options(extra: const {kAllowAnonymous: true});

  String _url(String suffix) =>
      Endpoints.publicUrl(_apiClient.dio.options.baseUrl, suffix);

  Future<Either<Failure, dynamic>> getOffers() {
    return _apiClient.get(
      _url(Endpoints.publicOffers),
      options: _anonymousFriendly,
    );
  }

  Future<Either<Failure, dynamic>> getOffer(String offerId) {
    return _apiClient.get(
      _url(Endpoints.publicOffer(offerId)),
      options: _anonymousFriendly,
    );
  }
}
