import 'package:dio/dio.dart';

abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.errMessage);

  factory ServerFailure.fromDioExeption(DioException dioExeption) {
    switch (dioExeption.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure('Connection timeout with ApiServer');

      case DioExceptionType.sendTimeout:
        return ServerFailure('Send timeout with ApiServer');

      case DioExceptionType.receiveTimeout:
        return ServerFailure('Receive timeout with ApiServer');

      case DioExceptionType.badResponse:
        return ServerFailure.fromBadResponse(
          dioExeption.response!.statusCode!,
          dioExeption.response!.data,
        );
      case DioExceptionType.cancel:
        return ServerFailure('Request to ApiServer was canceled');

      case DioExceptionType.unknown:
        if (dioExeption.message!.contains('SocketException')) {
          return ServerFailure('No Enternet Connection');
        }
        return ServerFailure('Unexpected Error, Please try again later');

      // case DioExceptionType.badCertificate:

      // case DioExceptionType.connectionError:

      default:
        return ServerFailure(
          'Opps, there was an Error, please try again later',
        );
    }
  }

  factory ServerFailure.fromBadResponse(int statusCode, dynamic response) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return ServerFailure(response['error']['message']);
    } else if (statusCode == 404) {
      return ServerFailure('Your request not fornd, please try again later');
    } else if (statusCode == 500) {
      return ServerFailure('Internal Server error, please try again later');
    } else {
      return ServerFailure('Oops, there was an Error, please try again later');
    }
  }
}

class LocationFailure extends Failure {
  LocationFailure(super.message);
}
