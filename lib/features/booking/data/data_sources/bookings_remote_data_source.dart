import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class BookingsRemoteDataSource {
  final APIClient _apiClient;

  BookingsRemoteDataSource(this._apiClient);

  /// [offerId] and [promoCode] are ALTERNATIVES, never companions: the server
  /// resolves an offer's linked promo code itself, and a body carrying both is
  /// a 400 (`promo-and-offer-mutually-exclusive`). The offer wins when both are
  /// somehow supplied — it is the richer binding, carrying the attribution the
  /// bare code cannot.
  Future<Either<Failure, dynamic>> getQuote({
    required String packageId,
    required double lat,
    required double lng,
    List<Map<String, dynamic>>? addOns,
    String? promoCode,
    String? offerId,
    List<String> addOnIds = const [],
    int? carCount,
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

  /// Pay-before-create step 2: re-validates the quote, soft-holds the slot,
  /// and returns {amountMinor, givenId, metadata} for the Moyasar SDK.
  ///
  /// `scheduledAt` is the bare ISO-8601 Saudi time string (no offset) matching
  /// the format produced by `toWireDateTime`
  /// (`core/utils/saudi_wire_format.dart`).
  /// `vehicles` is the 1-element list matching the shape in
  /// [ServiceBookingRequestModel.toJson] (savedVehicleId XOR denormalised fields).
  Future<Either<Failure, dynamic>> bookingPaymentInit({
    required String quoteId,
    required String scheduledAt,
    required List<Map<String, dynamic>> vehicles,
    required String idempotencyKey,
    required String attemptNonce,
  }) {
    return _apiClient.post(
      Endpoints.bookingsPaymentInit,
      data: {
        'quoteId': quoteId,
        'scheduledAt': scheduledAt,
        'vehicles': vehicles,
        'attemptNonce': attemptNonce,
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
}
