import 'package:dartz/dartz.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../models/banner_model.dart';
import '../data_source/banners_remote_data_source.dart';

class BannersRepository {
  final BannersRemoteDataSource _bannersDataSource;

  BannersRepository(this._bannersDataSource);

  Future<Either<Failure, List<BannerModel>>> fetchBanners() async {
    final result = await _bannersDataSource.getBanners();
    return result.fold((failure) => Left(failure), (data) {
      if (data != null) {
        try {
          final List<dynamic> list = data as List<dynamic>;
          final parsedBanners = list
              .map(
                (json) => BannerModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
          return Right(parsedBanners);
        } catch (e) {
          return Left(ServerFailure('Parsing error: $e'));
        }
      }
      return const Left(ServerFailure('Failed to load banners'));
    });
  }
}
