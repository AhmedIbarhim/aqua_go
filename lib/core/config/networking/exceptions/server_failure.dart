import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'failure.dart';

class ServerFailure extends Failure {
  static String get _defaultMessage => LocaleKeys.snackbar_default_error.tr();

  const ServerFailure(String message, {FailureType type = FailureType.unknown})
    : super(message, type);

  factory ServerFailure.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure(
          LocaleKeys.snackbar_connection_timeout.tr(),
          type: FailureType.timeout,
        );

      case DioExceptionType.sendTimeout:
        return ServerFailure(
          LocaleKeys.snackbar_connection_timeout.tr(),
          type: FailureType.timeout,
        );

      case DioExceptionType.receiveTimeout:
        return ServerFailure(
          LocaleKeys.snackbar_connection_timeout.tr(),
          type: FailureType.timeout,
        );

      case DioExceptionType.badCertificate:
        return const ServerFailure(
          'Bad certificate from server',
          type: FailureType.server,
        );

      case DioExceptionType.cancel:
        return ServerFailure(
          LocaleKeys.snackbar_connection_timeout.tr(),
          type: FailureType.cancelled,
        );

      case DioExceptionType.connectionError:
        return ServerFailure(
          LocaleKeys.snackbar_no_internet.tr(),
          type: FailureType.network,
        );

      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
          dioException.response?.statusCode,
          dioException.response?.data,
        );

      case DioExceptionType.unknown:
        if (dioException.error is SocketException) {
          return ServerFailure(
            LocaleKeys.snackbar_no_internet.tr(),
            type: FailureType.network,
          );
        }

        return ServerFailure(_defaultMessage);
    }
  }

  factory ServerFailure.fromResponse(int? statusCode, dynamic response) {
    if (response is Map) {
      final title = response['title']?.toString();
      final type = response['type']?.toString();
      if (title == 'Address outside service area' ||
          // type == 'https://qa-api.aquago.sa/errors/address-outside-service-area'
          type == 'https://api.aquago.sa/errors/address-outside-service-area'
      ) {
        return const ServerFailure(
          'address-outside-service-area',
          type: FailureType.validation,
        );
      }
    }

    final message = _extractErrorMessage(response);

    switch (statusCode) {
      case StatusCodes.badRequest:
      case StatusCodes.unprocessableEntity:
      case StatusCodes.conflict:
        return ServerFailure(message, type: FailureType.validation);

      case StatusCodes.unauthorized:
        return ServerFailure(message, type: FailureType.unauthorized);

      case StatusCodes.forbidden:
        return ServerFailure(message, type: FailureType.forbidden);

      case StatusCodes.notFound:
        return const ServerFailure(
          'Request not found',
          type: FailureType.notFound,
        );

      case StatusCodes.internalServerError:
      case StatusCodes.badGateway:
      case StatusCodes.serviceUnavailable:
        return ServerFailure(
          LocaleKeys.errors_internal_error.tr(),
          type: FailureType.server,
        );

      default:
        return ServerFailure(_defaultMessage);
    }
  }

  /// Joins the server-localized `message` strings from an RFC 9457
  /// `violations[]` array. `field`/`code` are reserved for LOGIC only and are
  /// never surfaced as display text. Returns null when no displayable message
  /// is present.
  static String? _extractViolations(dynamic response) {
    if (response is! Map) return null;
    final violations = response['violations'];
    if (violations is! List) return null;
    final messages = violations
        .whereType<Map>()
        .map((v) => v['message'])
        .whereType<String>()
        .where((m) => m.isNotEmpty)
        .toList();
    if (messages.isEmpty) return null;
    return messages.join('\n');
  }

  static String _extractErrorMessage(dynamic response) {
    try {
      if (response is! Map<String, dynamic>) {
        return _defaultMessage;
      }

      /// detail (RFC 9457 — canonical localized server string; wins)
      if (response['detail'] != null) {
        return response['detail'].toString();
      }

      /// violations[] (joined server `message` strings; logic uses code/field)
      final violations = _extractViolations(response);
      if (violations != null) {
        return violations;
      }

      /// message
      if (response['message'] != null) {
        return response['message'].toString();
      }

      /// title
      if (response['title'] != null) {
        return response['title'].toString();
      }

      /// error.message
      if (response['error'] is Map && response['error']['message'] != null) {
        return response['error']['message'].toString();
      }

      /// error
      if (response['error'] != null) {
        return response['error'].toString();
      }

      /// errors
      if (response['errors'] != null) {
        final errors = response['errors'];

        if (errors is Map) {
          final firstError = errors.values.first;

          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }

          return firstError.toString();
        }

        return errors.toString();
      }

      return _defaultMessage;
    } catch (_) {
      return _defaultMessage;
    }
  }
}
