import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/gifts/data/data_sources/gifts_remote_data_source.dart';
import 'package:aqua_go/features/gifts/data/models/gifts_list_response_model.dart';
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

  Future<Either<Failure, void>> redeemGift(String code) async {
    final result = await _remoteDataSource.redeemGift(code);
    return result.fold(
      (failure) => Left(failure),
      (data) => const Right(null),
    );
  }
}
