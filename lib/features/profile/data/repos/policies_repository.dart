import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/profile/data/data_sources/policies_remote_data_source.dart';
import 'package:aqua_go/features/profile/data/models/policy_model.dart';
import 'package:dartz/dartz.dart';

class PoliciesRepository {
  final PoliciesRemoteDataSource _remoteDataSource;

  PoliciesRepository(this._remoteDataSource);

  Future<Either<Failure, PolicyModel>> getPolicy({
    required String type,
    required String locale,
  }) async {
    final result = await _remoteDataSource.getPolicy(
      type: type,
      locale: locale,
    );
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final policy = PolicyModel.fromJson(data as Map<String, dynamic>);
            return Right(policy);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to load policy'));
      },
    );
  }
}
