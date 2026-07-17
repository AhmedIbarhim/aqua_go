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
    required String idempotencyKey,
    required Map<String, dynamic> data,
  }) {
    return _apiClient.post(
      Endpoints.gifts,
      data: data,
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
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

  Future<Either<Failure, dynamic>> getGiftQuote({
    required Map<String, dynamic> data,
  }) {
    return _apiClient.post(
      Endpoints.giftQuotes,
      data: data,
    );
  }

  Future<Either<Failure, dynamic>> giftPaymentInit({
    required String packageId,
    required List<String>? addOnIds,
    required int? pointsToApply,
    required String attemptNonce,
    required String idempotencyKey,
  }) {
    return _apiClient.post(
      Endpoints.giftPaymentInit,
      data: {
        'packageId': packageId,
        if (addOnIds != null && addOnIds.isNotEmpty) 'addOnIds': addOnIds,
        if (pointsToApply != null) 'pointsToApply': pointsToApply,
        'attemptNonce': attemptNonce,
      },
      options: Options(
        headers: {'Idempotency-Key': idempotencyKey},
      ),
    );
  }
}
