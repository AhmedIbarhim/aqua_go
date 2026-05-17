import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';

class BookingRepo {
  final APIClient apiClient;

  BookingRepo({required this.apiClient});

  Future<Either<Failure, void>> createBooking() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      return right(null);
    } catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }
}
