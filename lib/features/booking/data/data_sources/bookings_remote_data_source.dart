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
    List<Map<String, dynamic>>? addOns,
    String? promoCode,
    String? offerId,
    List<String> addOnIds = const [],
    int? carCount,
    int? pointsToApply,
  }) {
    final hasOffer = offerId != null && offerId.isNotEmpty;
    return _apiClient.post(
      Endpoints.quotes,
      data: {
        'packageId': packageId,
        'lat': lat,
        'lng': lng,
        if (hasOffer) 'offerId': offerId,
        if (!hasOffer && promoCode != null && promoCode.isNotEmpty)
          'promoCode': promoCode,
        if (addOnIds.isNotEmpty) ...{
          'addOns': addOnIds.map((id) => {'addonId': id}).toList(),
          'carCount': carCount ?? 1,
        },
        if (pointsToApply != null) 'pointsToApply': pointsToApply,
      },
    );
  }

  Future<Either<Failure, dynamic>> validatePromo({
    required String code,
    required String packageId,
    required double lat,
    required double lng,
  }) {
    return _apiClient.post(
      Endpoints.validatePromo,
      data: {'code': code, 'packageId': packageId, 'lat': lat, 'lng': lng},
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

  Future<Either<Failure, dynamic>> bookingPaymentInit({
    required String quoteId,
    required String scheduledAt,
    required List<Map<String, dynamic>> vehicles,
    required String idempotencyKey,
    required String attemptNonce,
    int? pointsToApply,
  }) {
    return _apiClient.post(
      Endpoints.bookingsPaymentInit,
      data: {
        'quoteId': quoteId,
        'scheduledAt': scheduledAt,
        'vehicles': vehicles,
        'attemptNonce': attemptNonce,
        if (pointsToApply != null) 'pointsToApply': pointsToApply,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
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

  Future<Either<Failure, dynamic>> previewScheduleSubscriptionWash({
    required String subscriptionId,
    required String washId,
    required Map<String, dynamic> scheduleData,
  }) {
    return _apiClient.post(
      Endpoints.previewScheduleSubscriptionWash(subscriptionId, washId),
      data: scheduleData,
    );
  }

  Future<Either<Failure, dynamic>> scheduleSubscriptionWash({
    required String subscriptionId,
    required String washId,
    required Map<String, dynamic> scheduleData,
    required String idempotencyKey,
  }) {
    return _apiClient.post(
      Endpoints.scheduleSubscriptionWash(subscriptionId, washId),
      data: scheduleData,
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
  }

  Future<Either<Failure, dynamic>> rescheduleSubscriptionWash({
    required String subscriptionId,
    required String washId,
    required Map<String, dynamic> rescheduleData,
    required String idempotencyKey,
  }) {
    return _apiClient.post(
      Endpoints.rescheduleSubscriptionWash(subscriptionId, washId),
      data: rescheduleData,
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
  }

  Future<Either<Failure, dynamic>> redeemGiftBooking({
    required Map<String, dynamic> data,
    required String idempotencyKey,
  }) {
    return _apiClient.post(
      Endpoints.redeemGift,
      data: data,
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
  }
}
