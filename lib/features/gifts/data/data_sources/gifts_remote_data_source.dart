import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';

class GiftsRemoteDataSource {
  final APIClient _apiClient;

  GiftsRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> getGifts({
    int limit = 20,
    String? cursor,
  }) {
    final Map<String, dynamic> queryParameters = {
      'limit': limit,
    };
    if (cursor != null && cursor.isNotEmpty) {
      queryParameters['cursor'] = cursor;
    }

    return _apiClient.get(
      Endpoints.gifts,
      queryParameters: queryParameters,
    );
  }

  Future<Either<Failure, dynamic>> redeemGift(String code) {
    return _apiClient.post(
      Endpoints.redeemGift,
      data: {'code': code},
    );
  }
}
