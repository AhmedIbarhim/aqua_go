import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/local_storage/secure_storage.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/core/route/app_router.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

class APIClient {
  late final Dio _dio;

  Dio get dio => _dio;

  APIClient({
    String? baseUrl,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final skipAuth = options.extra['skipAuth'] as bool? ?? false;
          if (!skipAuth) {
            final token = await SecureStorage.read(kAccessToken);
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException err, handler) async {
          // Only attempt token refresh on 401 Unauthorized
          if (err.response?.statusCode != 401) {
            return handler.next(err);
          }

          const int maxRefreshAttempts = 3;

          // Read how many refresh attempts have already been made for this request
          final int attemptsSoFar =
              (err.requestOptions.extra['refreshAttempts'] as int?) ?? 0;

          // Exhausted all retries → force logout
          if (attemptsSoFar >= maxRefreshAttempts) {
            await _clearSessionAndRedirect();
            return handler.next(err);
          }

          // Read the stored refresh token
          final storedRefreshToken = await SecureStorage.read(kRefreshToken);
          if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
            await _clearSessionAndRedirect();
            return handler.next(err);
          }

          try {
            // Call refresh endpoint directly without attaching the expired access token
            final refreshResponse = await _dio.post(
              '/auth/token/refresh',
              data: {'refreshToken': storedRefreshToken},
              options: Options(
                extra: const {
                  'skipAuth': true,
                  'refreshAttempts': maxRefreshAttempts,
                },
              ),
            );

            final newAccessToken =
                refreshResponse.data['accessToken'] as String?;
            final newRefreshToken =
                refreshResponse.data['refreshToken'] as String?;

            if (newAccessToken == null || newAccessToken.isEmpty) {
              await _clearSessionAndRedirect();
              return handler.next(err);
            }

            // Persist the new tokens
            await SecureStorage.write(kAccessToken, newAccessToken);
            if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
              await SecureStorage.write(kRefreshToken, newRefreshToken);
            }

            // Retry the original request, bumping the attempt counter
            final retryOptions = err.requestOptions.copyWith(
              headers: {
                ...err.requestOptions.headers,
                'Authorization': 'Bearer $newAccessToken',
              },
              extra: {
                ...err.requestOptions.extra,
                'refreshAttempts': attemptsSoFar + 1,
              },
            );

            final retryResponse = await _dio.fetch(retryOptions);
            return handler.resolve(retryResponse);
          } on DioException catch (_) {
            // Refresh request itself failed → session is truly expired
            await _clearSessionAndRedirect();
            return handler.next(err);
          } catch (_) {
            await _clearSessionAndRedirect();
            return handler.next(err);
          }
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(TalkerDioLogger());
    }
  }

  /// Wipes all local credentials and navigates to the login screen
  /// without requiring a BuildContext.
  Future<void> _clearSessionAndRedirect() async {
    await SecureStorage.delete(kAccessToken);
    await SecureStorage.delete(kRefreshToken);
    await SharedPrefs.removeString(kUserData);

    AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.login,
      (route) => false,
    );
  }

  Future<Either<Failure, Response<T>>> _request<T>(
    Future<Response<T>> Function() call,
  ) async {
    try {
      final response = await call();
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Response<T>>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(
    () => _dio.get<T>(path, queryParameters: queryParameters, options: options),
  );

  Future<Either<Failure, Response<T>>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(
    () => _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
  );

  Future<Either<Failure, Response<T>>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(
    () => _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
  );

  Future<Either<Failure, Response<T>>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(
    () => _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
  );

  Future<Either<Failure, Response<T>>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(
    () => _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
  );
}
