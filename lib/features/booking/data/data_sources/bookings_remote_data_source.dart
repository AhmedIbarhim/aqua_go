import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class BookingsRemoteDataSource {
  final APIClient _apiClient;

  BookingsRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> getQuote({
    required String packageId,
    required double lat,
    required double lng,
    String? promoCode,
  }) {
    return _apiClient.post(
      Endpoints.quotes,
      data: {
        'packageId': packageId,
        'lat': lat,
        'lng': lng,
        if (promoCode != null && promoCode.isNotEmpty) 'promoCode': promoCode,
      },
    );
  }

  Future<Either<Failure, dynamic>> checkZoneAvailability({
    required double lat,
    required double lng,
  }) {
    return _apiClient.post(Endpoints.zoneCheck, data: {'lat': lat, 'lng': lng});
  }

  Future<Either<Failure, dynamic>> getAvailability({
    required String zoneId,
    required String date,
    required String packageId,
  }) {
    return _apiClient.get(
      Endpoints.availability,
      queryParameters: {'zoneId': zoneId, 'date': date, 'packageId': packageId},
    );
  }

  Future<Either<Failure, dynamic>> createBooking({
    required Map<String, dynamic> bookingData,
    required String idempotencyKey,
  }) {
    return _apiClient.post(
      Endpoints.bookings,
      data: bookingData,
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
  }

  Future<Either<Failure, dynamic>> rescheduleBooking({
    required String bookingId,
    required Map<String, dynamic> rescheduleData,
    required String idempotencyKey,
  }) {
    return _apiClient.post(
      Endpoints.rescheduleBooking(bookingId),
      data: rescheduleData,
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
  }
}
