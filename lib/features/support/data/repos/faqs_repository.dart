import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/support/data/data_sources/faqs_remote_data_source.dart';
import 'package:aqua_go/features/support/data/models/Faq_model.dart';
import 'package:dartz/dartz.dart';

class FaqsRepository {
  final FaqsRemoteDataSource _remoteDataSource;

  FaqsRepository(this._remoteDataSource);

  Future<Either<Failure, List<FaqModel>>> getFaqs() async {
    final result = await _remoteDataSource.getFaqs();
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final List<dynamic> list = data as List<dynamic>;
            final faqs = list
                .map((json) => FaqModel.fromJson(json as Map<String, dynamic>))
                .toList();
            return Right(faqs);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to load FAQs'));
      },
    );
  }
}
