import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/booking_model.dart';

class BookingRepo {
  final APIClient apiClient;

  BookingRepo({required this.apiClient});

  Future<Either<Failure, bool>> checkZoneAvailability(
    double lat,
    double lng,
  ) async {
    try {
      final response = await apiClient.post<dynamic>(
        Endpoints.zoneCheck,
        data: {'lat': lat, 'lng': lng},
      );
      return response.fold((failure) => left(failure), (data) {
        final inServiceArea = data?['inServiceArea'] as bool? ?? false;
        return right(inServiceArea);
      });
    } catch (error) {
      return left(ServerFailure(error.toString(), type: FailureType.unknown));
    }
  }

  Future<Either<Failure, void>> createBooking(BookingModel booking) async {
    try {
      final response = await apiClient.post<dynamic>(
        Endpoints.bookings,
        data: booking.toJson(),
      );
      return response.fold((failure) => left(failure), (_) => right(null));
    } catch (error) {
      return left(ServerFailure(error.toString(), type: FailureType.unknown));
    }
  }
}
