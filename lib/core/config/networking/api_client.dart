import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../errors/failure.dart';

class APIClient {
  final Dio _dio;

  APIClient(this._dio);

  Dio get dio => _dio;

  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? parser,
  }) {
    return _request(
      () => _dio.get(path, queryParameters: queryParameters, options: options),
      parser,
    );
  }

  Future<Either<Failure, T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? parser,
  }) {
    return _request(
      () => _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      parser,
    );
  }

  Future<Either<Failure, T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? parser,
  }) {
    return _request(
      () => _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      parser,
    );
  }

  Future<Either<Failure, T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? parser,
  }) {
    return _request(
      () => _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      parser,
    );
  }

  Future<Either<Failure, T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? parser,
  }) {
    return _request(
      () => _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      parser,
    );
  }

  Future<Either<Failure, T>> _request<T>(
    Future<Response> Function() request,
    T Function(dynamic data)? parser,
  ) async {
    try {
      final response = await request();

      final dynamic responseData = response.data;

      if (parser != null) {
        return Right(parser(responseData));
      }

      return Right(responseData as T);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString(), type: FailureType.unknown));
    }
  }
}
