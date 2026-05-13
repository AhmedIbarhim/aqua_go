import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';

class BookingRepo {
  final APIClient apiClient;

  BookingRepo({required this.apiClient});

  Future<Either<Failure, void>> createBooking() async {
    // try {

    // } catch (error) {
    //   if (error is DioException) {
    //     return left(ServerFailure.fromDioExeption(error));
    //   }
    //   return left(ServerFailure(error.toString()));
    // }

    throw UnimplementedError();
  }
}
