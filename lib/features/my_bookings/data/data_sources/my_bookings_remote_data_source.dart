import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';

class MyBookingsRemoteDataSource {
  final APIClient _apiClient;

  MyBookingsRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> getBookings({
    int limit = 20,
    String? cursor,
  }) {
    final Map<String, dynamic> queryParameters = {
      'limit': limit,
    };
    if (cursor != null && cursor.isNotEmpty) {
      queryParameters['cursor'] = cursor;
    }

    return _apiClient.get(
      Endpoints.bookings,
      queryParameters: queryParameters,
    );
  }

  Future<Either<Failure, dynamic>> getBookingDetails(String id) {
    return _apiClient.get(Endpoints.bookingDetail(id));
  }
}
