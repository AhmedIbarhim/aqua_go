import 'package:dio/dio.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/local_storage/secure_storage.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/core/route/app_router.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';

class RefreshTokenInterceptor extends Interceptor {
  final Dio dio;

  // Cache the ongoing refresh request future to prevent concurrent refresh calls
  Future<String?>? _refreshFuture;
  bool _isRedirecting = false;

  RefreshTokenInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
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
    final storedRefreshToken = await SecureStorage.getSecuredString(
      kRefreshToken,
    );
    if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
      await _clearSessionAndRedirect();
      return handler.next(err);
    }

    try {
      // If a refresh is already in progress, wait for it instead of starting a new one
      _refreshFuture ??= _refreshToken(storedRefreshToken);
      final newAccessToken = await _refreshFuture;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        await _clearSessionAndRedirect();
        return handler.next(err);
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

      final retryResponse = await dio.fetch(retryOptions);
      return handler.resolve(retryResponse);
    } on DioException catch (_) {
      // Refresh request itself failed → session is truly expired
      await _clearSessionAndRedirect();
      return handler.next(err);
    } catch (_) {
      await _clearSessionAndRedirect();
      return handler.next(err);
    }
  }

  /// Performs the actual refresh request, saves the new tokens, and resets the future when finished.
  Future<String?> _refreshToken(String storedRefreshToken) async {
    try {
      // Use a separate Dio instance specifically for refresh
      // to bypass interceptors and avoid circular loops
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final refreshResponse = await refreshDio.post(
        Endpoints.refreshToken,
        data: {'refreshToken': storedRefreshToken},
      );

      final newAccessToken = refreshResponse.data['accessToken'] as String?;
      final newRefreshToken = refreshResponse.data['refreshToken'] as String?;

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        // Persist the new tokens
        await SecureStorage.saveSecuredString(kAccessToken, newAccessToken);
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await SecureStorage.saveSecuredString(kRefreshToken, newRefreshToken);
        }
      }
      return newAccessToken;
    } finally {
      // Reset the future so subsequent failures in the future can trigger a new refresh flow
      _refreshFuture = null;
    }
  }

  /// Wipes all local credentials and navigates to the login screen
  /// without requiring a BuildContext.
  Future<void> _clearSessionAndRedirect() async {
    if (_isRedirecting) return;
    _isRedirecting = true;

    await SecureStorage.deleteSecuredString(kAccessToken);
    await SecureStorage.deleteSecuredString(kRefreshToken);
    await CacheClient.removeString(kUserData);

    AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.login,
      (route) => false,
    );
  }
}
