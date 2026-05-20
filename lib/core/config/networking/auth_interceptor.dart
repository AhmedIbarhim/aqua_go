import 'package:dio/dio.dart';
import 'package:aqua_go/core/config/local_storage/secure_storage.dart';
import 'package:aqua_go/core/constants.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skipAuth = options.extra['skipAuth'] as bool? ?? false;

    if (!skipAuth) {
      final token = await SecureStorage.getSecuredString(kAccessToken);

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }
}
