import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/service_model.dart';
import '../data_source/services_remote_data_source.dart';

class ServicesRepository {
  final ServicesRemoteDataSource _servicesDataSource;

  ServicesRepository(this._servicesDataSource);

  Future<Either<Failure, List<ServiceModel>>> fetchServices() async {
    final result = await _servicesDataSource.getServices();
    return result.fold(
      (failure) => Left(failure),
      (response) {
        if (response.statusCode == 200 && response.data != null) {
          try {
            final List<dynamic> list = response.data as List<dynamic>;
            final parsedServices = list
                .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
                .toList();
            return Right(parsedServices);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to load services'));
      },
    );
  }
}
