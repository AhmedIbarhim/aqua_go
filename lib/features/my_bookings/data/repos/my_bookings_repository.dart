import 'dart:typed_data';

import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/my_bookings/data/data_sources/my_bookings_remote_data_source.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
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
    return result.fold((failure) => Left(failure), (data) {
      if (data != null) {
        try {
          final listResponse = BookingsListResponseModel.fromJson(
            data as Map<String, dynamic>,
          );
          return Right(listResponse);
        } catch (e) {
          return Left(ServerFailure('Parsing error: $e'));
        }
      }
      return const Left(ServerFailure('Failed to load bookings'));
    });
  }

  Future<Either<Failure, List<BookingResponseModel>>>
  getPendingRatings() async {
    final result = await _remoteDataSource.getPendingRatings();
    return result.fold((failure) => Left(failure), (data) {
      if (data is List) {
        try {
          final bookings = data
              .map(
                (e) => BookingResponseModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
          return Right(bookings);
        } catch (e) {
          return Left(ServerFailure('Parsing error: $e'));
        }
      }
      // Treat a null/empty body as "nothing pending" rather than an error.
      return const Right(<BookingResponseModel>[]);
    });
  }

  Future<Either<Failure, BookingResponseModel>> getBookingDetails(
    String id,
  ) async {
    final result = await _remoteDataSource.getBookingDetails(id);
    return result.fold((failure) => Left(failure), (data) {
      if (data != null) {
        try {
          final details = BookingResponseModel.fromJson(
            data as Map<String, dynamic>,
          );
          return Right(details);
        } catch (e) {
          return Left(ServerFailure('Parsing error: $e'));
        }
      }
      return const Left(ServerFailure('Failed to load booking details'));
    });
  }

  Future<Either<Failure, Uint8List>> downloadReceiptPdf(String bookingId) {
    return _remoteDataSource.downloadReceiptPdf(bookingId);
  }
}
