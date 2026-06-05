import 'package:dartz/dartz.dart';
import '../../../../core/config/networking/api_client.dart';
import '../../../../core/config/networking/endpoints.dart';
import '../../../../core/config/networking/exceptions/failure.dart';

class RatingRemoteDataSource {
  final APIClient _apiClient;

  RatingRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> rateBooking({
    required String bookingId,
    required Map<String, dynamic> ratingData,
  }) {
    return _apiClient.post(Endpoints.rateBooking(bookingId), data: ratingData);
  }
}
