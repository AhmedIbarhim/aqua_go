import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'failure.dart';

class ServerFailure extends Failure {
  static String get _defaultMessage => LocaleKeys.snackbar_default_error.tr();

  final String? slug;

  const ServerFailure(
    String message, {
    FailureType type = FailureType.unknown,
    this.slug,
  }) : super(message, type);

  @override
  List<Object?> get props => [...super.props, slug];

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

      default:
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
    final slug = _extractSlug(response);

    if (response is Map) {
      final title = response['title']?.toString();
      if (title == 'Address outside service area' ||
          slug == 'address-outside-service-area') {
        return const ServerFailure(
          'address-outside-service-area',
          type: FailureType.validation,
          slug: 'address-outside-service-area',
        );
      }
    }

    final message = _extractErrorMessage(response);

    switch (statusCode) {
      case StatusCodes.badRequest:
      case StatusCodes.unprocessableEntity:
      case StatusCodes.conflict:
        return ServerFailure(message, type: FailureType.validation, slug: slug);

      case StatusCodes.unauthorized:
        return ServerFailure(
          message,
          type: FailureType.unauthorized,
          slug: slug,
        );

      case StatusCodes.forbidden:
        return ServerFailure(message, type: FailureType.forbidden, slug: slug);

      case StatusCodes.notFound:
        return ServerFailure(message, type: FailureType.notFound, slug: slug);

      case StatusCodes.internalServerError:
      case StatusCodes.badGateway:
      case StatusCodes.serviceUnavailable:
        return ServerFailure(
          _hasProblemDetail(response)
              ? message
              : LocaleKeys.errors_internal_error.tr(),
          type: FailureType.server,
          slug: slug,
        );

      default:
        return ServerFailure(_defaultMessage, slug: slug);
    }
  }

  static String? _extractSlug(dynamic response) {
    if (response is! Map) return null;
    final raw = response['type']?.toString();
    if (raw == null || raw.isEmpty || raw == 'about:blank') return null;
    final segment = raw.split('/').last.trim();
    return segment.isEmpty ? null : segment;
  }

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

  static bool _hasProblemDetail(dynamic response) {
    if (response is! Map) return false;
    final detail = response['detail']?.toString();
    if (detail != null && detail.isNotEmpty) return true;
    final title = response['title']?.toString();
    return title != null && title.isNotEmpty;
  }

  static String _extractErrorMessage(dynamic response) {
    try {
      if (response is! Map<String, dynamic>) {
        return _defaultMessage;
      }

      if (response['detail'] != null) {
        return response['detail'].toString();
      }

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
