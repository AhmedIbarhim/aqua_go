import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => '$runtimeType: $message';
}

class ServerFailure extends Failure {
  const ServerFailure(super.errMessage);

  factory ServerFailure.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return const ServerFailure('Connection timeout with ApiServer');

      case DioExceptionType.sendTimeout:
        return const ServerFailure('Send timeout with ApiServer');

      case DioExceptionType.receiveTimeout:
        return const ServerFailure('Receive timeout with ApiServer');

      case DioExceptionType.connectionError:
        return const ServerFailure('No Internet Connection');

      case DioExceptionType.badResponse:
        return ServerFailure.fromBadResponse(
          dioException.response?.statusCode ?? 0,
          dioException.response?.data,
        );
      case DioExceptionType.cancel:
        return const ServerFailure('Request to ApiServer was canceled');

      case DioExceptionType.unknown:
        if (dioException.message != null && dioException.message!.contains('SocketException')) {
          return const ServerFailure('No Internet Connection');
        }
        return const ServerFailure('Unexpected Error, Please try again later');

      default:
        return const ServerFailure(
          'Opps, there was an Error, please try again later',
        );
    }
  }

  factory ServerFailure.fromBadResponse(int statusCode, dynamic response) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403 || statusCode == 422) {
      if (response is Map) {
        if (response['error'] is Map && response['error']['message'] != null) {
          return ServerFailure(response['error']['message'].toString());
        } else if (response['message'] != null) {
          return ServerFailure(response['message'].toString());
        } else if (response['error'] != null) {
          return ServerFailure(response['error'].toString());
        } else if (response['errors'] != null) {
          if (response['errors'] is Map) {
            final firstError = (response['errors'] as Map).values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return ServerFailure(firstError.first.toString());
            }
            return ServerFailure(firstError.toString());
          }
          return ServerFailure(response['errors'].toString());
        }
      }
      return const ServerFailure('Oops, there was an Error, please try again later');
    } else if (statusCode == 404) {
      return const ServerFailure('Your request not found, please try again later');
    } else if (statusCode == 500) {
      return const ServerFailure('Internal Server error, please try again later');
    } else {
      return const ServerFailure('Oops, there was an Error, please try again later');
    }
  }
}

class LocationFailure extends Failure {
  const LocationFailure(super.message);
}
