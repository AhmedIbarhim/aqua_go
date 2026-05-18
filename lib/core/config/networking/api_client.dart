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
          final token = await SecureStorage.read(kAccessToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (err, handler) async {
          if (err.response?.statusCode == 401) {
            // Delete security credentials locally
            await SecureStorage.delete(kAccessToken);
            await SecureStorage.delete(kRefreshToken);
            await SharedPrefs.removeString(kUserData);

            // Redirect context-free to login screen
            AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
              Routes.login,
              (route) => false,
            );
            return handler.reject(err);
          }
          return handler.next(err);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(TalkerDioLogger());
    }
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
  }) => _request(() => _dio.get<T>(path, queryParameters: queryParameters, options: options));

  Future<Either<Failure, Response<T>>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(() => _dio.post<T>(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  ));

  Future<Either<Failure, Response<T>>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(() => _dio.put<T>(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  ));

  Future<Either<Failure, Response<T>>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(() => _dio.patch<T>(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  ));

  Future<Either<Failure, Response<T>>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(() => _dio.delete<T>(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  ));
}
