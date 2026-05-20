import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import 'auth_interceptor.dart';
import 'refresh_token_interceptor.dart';

class DioFactory {
  static Dio create({
    required String baseUrl,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(),
      RefreshTokenInterceptor(dio),
    ]);

    if (kDebugMode) {
      dio.interceptors.add(
        TalkerDioLogger(),
      );
    }

    return dio;
  }
}
