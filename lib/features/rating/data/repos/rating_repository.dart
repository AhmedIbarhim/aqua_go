import 'dart:convert';
import 'dart:developer' as developer;
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/rating/data/data_sources/rating_remote_data_source.dart';
import 'package:aqua_go/features/rating/data/models/rating_model.dart';
import 'package:dartz/dartz.dart';

class RatingRepository {
  final RatingRemoteDataSource _remoteDataSource;

  RatingRepository(this._remoteDataSource);

  Future<Either<Failure, RatingModel>> rateBooking({
    required String bookingId,
    required int score,
    String? comment,
    List<String>? reasons,
  }) async {
    try {
      final Map<String, dynamic> ratingData = {
        'score': score,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
        if (reasons != null && reasons.isNotEmpty) 'reasons': reasons,
      };

      final result = await _remoteDataSource.rateBooking(
        bookingId: bookingId,
        ratingData: ratingData,
      );

      return result.fold((failure) => Left(failure), (data) {
        if (data != null) {
          try {
            Map<String, dynamic> jsonMap;
            if (data is Map<String, dynamic>) {
              jsonMap = data;
            } else if (data is String) {
              try {
                final decoded = jsonDecode(data);
                if (decoded is Map<String, dynamic>) {
                  jsonMap = decoded;
                } else {
                  jsonMap = ratingData;
                }
              } catch (_) {
                jsonMap = ratingData;
              }
            } else {
              jsonMap = ratingData;
            }
            final rating = RatingModel.fromJson(jsonMap);
            return Right(rating);
          } catch (e, stackTrace) {
            developer.log(
              'Rating parsing exception: $e',
              error: e,
              stackTrace: stackTrace,
            );
            return Left(
              ServerFailure('Parsing error: $e. Response was: $data'),
            );
          }
        }
        return const Left(ServerFailure('Failed to submit rating'));
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
