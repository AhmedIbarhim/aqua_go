import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/my_bookings/data/data_sources/my_bookings_remote_data_source.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model.dart';
import 'package:dartz/dartz.dart';

class MyBookingsRepository {
  final MyBookingsRemoteDataSource _remoteDataSource;

  MyBookingsRepository(this._remoteDataSource);

  Future<Either<Failure, BookingsListResponseModel>> getBookings({
    int limit = 20,
    String? cursor,
  }) async {
    final result = await _remoteDataSource.getBookings(
      limit: limit,
      cursor: cursor,
    );
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final listResponse = BookingsListResponseModel.fromJson(data as Map<String, dynamic>);
            return Right(listResponse);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to load bookings'));
      },
    );
  }

  Future<Either<Failure, BookingResponseModel>> getBookingDetails(String id) async {
    final result = await _remoteDataSource.getBookingDetails(id);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final details = BookingResponseModel.fromJson(data as Map<String, dynamic>);
            return Right(details);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to load booking details'));
      },
    );
  }
}
