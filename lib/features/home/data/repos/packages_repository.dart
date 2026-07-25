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

  /// Single-package read for the package-detail screen. The customer surface
  /// exposes only the public list endpoint (`GET /api/customer/subscription-packages`),
  /// so the id is resolved against that list; an id that is absent means the
  /// package was deactivated or archived since the offer was rendered.
  Future<Either<Failure, PackageModel>> fetchPackageById(String packageId) async {
    final result = await fetchPackages();
    return result.fold((failure) => Left(failure), (packages) {
      for (final package in packages) {
        if (package.id == packageId) return Right(package);
      }
      return const Left(ServerFailure('PACKAGE_NOT_FOUND'));
    });
  }
}
