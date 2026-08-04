import 'dart:typed_data';

import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

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

  /// Completed-but-unrated bookings inside the live 7-day rating window
  /// (AQG-160). Returns a bare JSON array of BookingResponse, most-recent first.
  Future<Either<Failure, dynamic>> getPendingRatings() {
    return _apiClient.get(Endpoints.pendingRating);
  }

  /// Raw PDF bytes off `GET /bookings/{id}/receipt.pdf` — JWT-authenticated
  /// and ownership-gated, so this MUST go through `_apiClient` (the shared
  /// Dio instance carrying `AuthInterceptor`), never a bare `launchUrl`/http
  /// call, or the server 401s.
  Future<Either<Failure, Uint8List>> downloadReceiptPdf(String bookingId) {
    return _apiClient.get<Uint8List>(
      Endpoints.bookingReceiptPdf(bookingId),
      options: Options(responseType: ResponseType.bytes),
    );
  }
}
