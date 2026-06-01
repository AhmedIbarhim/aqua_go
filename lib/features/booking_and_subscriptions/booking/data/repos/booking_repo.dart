import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/helpers/fetch_user_data_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../core/config/networking/exceptions/failure.dart';
import '../models/booking_request_model.dart';
import '../models/quote_model.dart';

import '../models/availability_response_model.dart';

class BookingRepo {
  final APIClient apiClient;

  BookingRepo({required this.apiClient});

  Future<Either<Failure, QuoteModel>> getQuote({
    required String packageId,
    required double lat,
    required double lng,
    String? promoCode,
  }) async {
    try {
      final response = await apiClient.post<dynamic>(
        Endpoints.quotes,
        data: {
          'packageId': packageId,
          'lat': lat,
          'lng': lng,
          if (promoCode != null && promoCode.isNotEmpty) 'promoCode': promoCode,
        },
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
      final response = await apiClient.post<dynamic>(
        Endpoints.zoneCheck,
        data: {'lat': lat, 'lng': lng},
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
      return await apiClient.get<AvailabilityResponse>(
        Endpoints.availability,
        queryParameters: {
          'zoneId': zoneId,
          'date': date,
          'packageId': packageId,
        },
        parser: (data) => AvailabilityResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> createBooking(
    BookingRequestModel booking,
  ) async {
    try {
      final userId = FetchUserData.getUserId();
      final nowToMinutes = DateTime.now().toIso8601String().substring(0, 16);
      final idempotencyKey = '${userId}_$nowToMinutes';

      final response = await apiClient.post<dynamic>(
        Endpoints.bookings,
        data: booking.toJson(),
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );
      return response.fold((failure) => left(failure), (_) => right(null));
    } catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }
}
