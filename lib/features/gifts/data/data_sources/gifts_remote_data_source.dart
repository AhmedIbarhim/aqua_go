import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class GiftsRemoteDataSource {
  final APIClient _apiClient;

  GiftsRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> getGifts({int limit = 20, String? cursor}) {
    final Map<String, dynamic> queryParameters = {'limit': limit};
    if (cursor != null && cursor.isNotEmpty) {
      queryParameters['cursor'] = cursor;
    }

    return _apiClient.get(Endpoints.gifts, queryParameters: queryParameters);
  }

  Future<Either<Failure, dynamic>> getGiftThemes() {
    return _apiClient.get(Endpoints.giftThemes);
  }

  Future<Either<Failure, dynamic>> purchaseGift({
    required String giftId,
    required Map<String, dynamic> data,
  }) {
    return _apiClient.post(
      Endpoints.gifts,
      data: data,
      options: Options(headers: {'Idempotency-Key': 'gift-purchase:$giftId'}),
    );
  }

  Future<Either<Failure, dynamic>> cancelGift({required String giftId}) {
    return _apiClient.post(
      Endpoints.cancelGift(giftId),
      options: Options(headers: {'Idempotency-Key': 'gift-refund:$giftId'}),
    );
  }

  Future<Either<Failure, dynamic>> redeemGift(String code) {
    return _apiClient.post(Endpoints.redeemGift, data: {'code': code});
  }
}
