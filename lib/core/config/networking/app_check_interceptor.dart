import 'package:dio/dio.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

/// Attaches a Firebase App Check attestation token to every request as
/// `X-Firebase-AppCheck`. Best-effort: a token fetch that fails or returns null
/// must never block the request — the backend decides enforcement (default off).
/// R-15: the token is not PII and is never logged (Talker suppresses headers).
class AppCheckInterceptor extends Interceptor {
  AppCheckInterceptor({FirebaseAppCheck? appCheck})
      : _appCheck = appCheck ?? FirebaseAppCheck.instance;

  final FirebaseAppCheck _appCheck;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _appCheck.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['X-Firebase-AppCheck'] = token;
      }
    } catch (_) {
      // Never block a request on attestation — advisory header only.
    }
    handler.next(options);
  }
}
