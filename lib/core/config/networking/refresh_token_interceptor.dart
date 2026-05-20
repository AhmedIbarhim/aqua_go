import 'package:dio/dio.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/local_storage/secure_storage.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/core/route/app_router.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';

class RefreshTokenInterceptor extends Interceptor {
  final Dio dio;

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
    final storedRefreshToken = await SecureStorage.read(kRefreshToken);
    if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
      await _clearSessionAndRedirect();
      return handler.next(err);
    }

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
}
