import 'package:dio/dio.dart';
import 'package:aqua_go/core/config/local_storage/secure_storage.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
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

    // Emit the persisted locale as 'ar' | 'en' (no country code — the backend
    // catalog locales are ar/en/bn) so the backend renders RFC 9457 `detail`
    // strings in the user's language. Interceptors have no BuildContext — read
    // the persisted locale from the same store the app uses at startup
    // (CacheClient kLanguage -> 'ar' | 'en').
    final lang =
        CacheClient.getString(kLanguage, defaultValue: kArabicLang);
    options.headers['Accept-Language'] = lang == kArabicLang ? 'ar' : 'en';

    handler.next(options);
  }
}
