import 'package:dartz/dartz.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../models/package_model.dart';
import '../data_source/packages_remote_data_source.dart';

class PackagesRepository {
  final PackagesRemoteDataSource _packagesDataSource;

  PackagesRepository(this._packagesDataSource);

  Future<Either<Failure, List<PackageModel>>> fetchPackages() async {
    final result = await _packagesDataSource.getPackages();
    return result.fold((failure) => Left(failure), (data) {
      if (data != null) {
        try {
          final List<dynamic> list = data as List<dynamic>;
          final parsedPackages = list
              .map(
                (json) => PackageModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
          return Right(parsedPackages);
        } catch (e) {
          return Left(ServerFailure('Parsing error: $e'));
        }
      }
      return const Left(ServerFailure('Failed to load packages'));
    });
  }
}
