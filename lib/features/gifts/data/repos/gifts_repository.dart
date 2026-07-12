import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/gifts/data/data_sources/gifts_remote_data_source.dart';
import 'package:aqua_go/features/gifts/data/models/gifts_list_response_model.dart';
import 'package:aqua_go/features/gifts/data/models/gift_model.dart';
import 'package:aqua_go/features/gifts/data/models/gift_theme_model.dart';
import 'package:dartz/dartz.dart';

class GiftsRepository {
  final GiftsRemoteDataSource _remoteDataSource;

  GiftsRepository(this._remoteDataSource);

  Future<Either<Failure, GiftsListResponseModel>> getGifts({
    int limit = 20,
    String? cursor,
  }) async {
    final result = await _remoteDataSource.getGifts(
      limit: limit,
      cursor: cursor,
    );
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final listResponse = GiftsListResponseModel.fromJson(data as Map<String, dynamic>);
            return Right(listResponse);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to load gifts'));
      },
    );
  }

  Future<Either<Failure, List<GiftThemeModel>>> getGiftThemes() async {
    final result = await _remoteDataSource.getGiftThemes();
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data is List) {
          try {
            final themes = data
                .map((e) => GiftThemeModel.fromJson(e as Map<String, dynamic>))
                .toList();
            return Right(themes);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to load gift themes'));
      },
    );
  }

  Future<Either<Failure, GiftModel>> purchaseGift({
    required String giftId,
    required Map<String, dynamic> data,
  }) async {
    final result = await _remoteDataSource.purchaseGift(
      giftId: giftId,
      data: data,
    );
    return result.fold(
      (failure) => Left(failure),
      (response) {
        if (response != null) {
          try {
            final gift = GiftModel.fromJson(response as Map<String, dynamic>);
            return Right(gift);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to purchase gift'));
      },
    );
  }

  Future<Either<Failure, void>> cancelGift({
    required String giftId,
  }) async {
    final result = await _remoteDataSource.cancelGift(giftId: giftId);
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  Future<Either<Failure, void>> redeemGift(String code) async {
    final result = await _remoteDataSource.redeemGift(code);
    return result.fold(
      (failure) => Left(failure),
      (data) => const Right(null),
    );
  }
}
