import 'package:aqua_go/core/helpers/fetch_user_data_helper.dart';
import 'package:aqua_go/core/helpers/idempotency_key_helper.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../models/booking_request_model.dart';
import '../models/reschedule_request_model.dart';
import '../models/quote_model.dart';
import '../models/availability_response_model.dart';
import '../data_sources/bookings_remote_data_source.dart';

class BookingRepository {
  final BookingsRemoteDataSource bookingsRemoteDataSource;

  BookingRepository({required this.bookingsRemoteDataSource});

  Future<Either<Failure, QuoteModel>> getQuote({
    required String packageId,
    required double lat,
    required double lng,
    String? promoCode,
  }) async {
    try {
      final response = await bookingsRemoteDataSource.getQuote(
        packageId: packageId,
        lat: lat,
        lng: lng,
        promoCode: promoCode,
      );
      return response.fold((failure) => left(failure), (data) {
        if (data != null) {
          try {
            final quote = QuoteModel.fromJson(data as Map<String, dynamic>);
            return right(quote);
          } catch (e) {
            return left(ServerFailure('Parsing error: $e'));
          }
        }
        return left(ServerFailure('Failed to load quote details'));
      });
    } catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> checkZoneAvailability(
    double lat,
    double lng,
  ) async {
    try {
      final response = await bookingsRemoteDataSource.checkZoneAvailability(
        lat: lat,
        lng: lng,
      );
      return response.fold(
        (failure) => left(failure),
        (data) => right(data as Map<String, dynamic>),
      );
    } catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  Future<Either<Failure, AvailabilityResponse>> getAvailability({
    required String zoneId,
    required String date,
    required String packageId,
  }) async {
    try {
      final response = await bookingsRemoteDataSource.getAvailability(
        zoneId: zoneId,
        date: date,
        packageId: packageId,
      );
      return response.fold((failure) => left(failure), (data) {
        if (data != null) {
          try {
            final availability = AvailabilityResponse.fromJson(
              data as Map<String, dynamic>,
            );
            return right(availability);
          } catch (e) {
            return left(ServerFailure('Parsing error: $e'));
          }
        }
        return left(ServerFailure('Failed to load availability details'));
      });
    } catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  Future<Either<Failure, BookingResponseModel>> createBooking(
    BookingRequestModel booking,
  ) async {
    try {
      final idempotencyKey = IdempotencyKeyHelper.generate(
        userId: FetchUserData.getUserId() ?? '',
      );

      final response = await bookingsRemoteDataSource.createBooking(
        bookingData: booking.toJson(),
        idempotencyKey: idempotencyKey,
      );
      return response.fold((failure) => left(failure), (data) {
        if (data != null) {
          try {
            final bookingResponse = BookingResponseModel.fromJson(
              data as Map<String, dynamic>,
            );
            return right(bookingResponse);
          } catch (e) {
            return left(ServerFailure('Parsing error: $e'));
          }
        }
        return left(ServerFailure('Failed to load created booking details'));
      });
    } catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  Future<Either<Failure, BookingResponseModel>> rescheduleBooking(
    RescheduleRequestModel rescheduleRequest,
  ) async {
    try {
      final idempotencyKey = IdempotencyKeyHelper.generate(
        prefix: 'reschedule',
        userId: FetchUserData.getUserId() ?? '',
        requestId: rescheduleRequest.bookingId,
      );

      final response = await bookingsRemoteDataSource.rescheduleBooking(
        bookingId: rescheduleRequest.bookingId,
        rescheduleData: rescheduleRequest.toJson(),
        idempotencyKey: idempotencyKey,
      );
      return response.fold((failure) => left(failure), (data) {
        if (data != null) {
          try {
            final bookingResponse = BookingResponseModel.fromJson(
              data as Map<String, dynamic>,
            );
            return right(bookingResponse);
          } catch (e) {
            return left(ServerFailure('Parsing error: $e'));
          }
        }
        return left(ServerFailure('Failed to reschedule booking'));
      });
    } catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }
}
