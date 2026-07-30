import 'package:aqua_go/core/config/networking/anonymous_session_policy.dart';
import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

/// Reads the public offers feed. These endpoints are permitAll with an OPTIONAL
/// bearer — a guest sees the anonymous subset, a signed-in customer sees their
/// eligible subset. Every request is tagged kAllowAnonymous so a 401 / absent
/// token never tears the session down.
class OffersRemoteDataSource {
  final APIClient _apiClient;

  OffersRemoteDataSource(this._apiClient);

  /// dio's `Options` has a NON-const generative constructor (its initializer
  /// list runs asserts), so this can never be a `const` field — a `static const
  /// Options(...)` fails to compile. A getter also guarantees each request
  /// composes from a fresh instance instead of sharing one mutable object.
  Options get _anonymousFriendly => Options(extra: const {kAllowAnonymous: true});

  String _url(String suffix) =>
      Endpoints.publicUrl(_apiClient.dio.options.baseUrl, suffix);

  Future<Either<Failure, dynamic>> getOffers() {
    return _apiClient.get(_url(Endpoints.publicOffers), options: _anonymousFriendly);
  }

  Future<Either<Failure, dynamic>> getOffer(String offerId) {
    return _apiClient.get(
      _url(Endpoints.publicOffer(offerId)),
      options: _anonymousFriendly,
    );
  }
}
