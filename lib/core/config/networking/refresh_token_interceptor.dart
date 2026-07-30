import 'package:dio/dio.dart';
import 'package:aqua_go/core/config/local_storage/secure_storage.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/core/route/app_router.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/features/auth/data/repos/auth_repository.dart';
import 'package:aqua_go/core/config/networking/anonymous_session_policy.dart';

class RefreshTokenInterceptor extends Interceptor {
  final Dio dio;

  // Cache the ongoing refresh request future to prevent concurrent refresh calls
  // (single-flight). Carries the tri-state result so every concurrent waiter
  // sees the SAME outcome (ok / auth-dead / transient).
  Future<_RefreshResult>? _refreshFuture;
  bool _isRedirecting = false;

  RefreshTokenInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;
    final isAuthRequest =
        path.contains(Endpoints.sendOtp) ||
        path.contains(Endpoints.verifyOtp) ||
        path.contains(Endpoints.refreshToken);

    if (isAuthRequest) {
      return handler.next(err);
    }

    final accessToken = await SecureStorage.getSecuredString(kAccessToken);
    final refreshToken = await SecureStorage.getSecuredString(kRefreshToken);
    if ((accessToken == null || accessToken.isEmpty) &&
        (refreshToken == null || refreshToken.isEmpty)) {
      // No credentials at all — this is a signed-out user. Only a 401 from an
      // endpoint that was NOT declared anonymous justifies wiping state and
      // bouncing to login; a 404 / 5xx / timeout on a public browse must leave
      // the guest exactly where they are (UCC23 A4).
      final allowAnonymous = err.requestOptions.extra[kAllowAnonymous] == true;
      if (shouldTearDownTokenlessSession(
        allowAnonymous: allowAnonymous,
        statusCode: err.response?.statusCode,
      )) {
        await _clearSessionAndRedirect();
      }
      return handler.next(err);
    }

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
      // If a refresh is already in progress, wait for it instead of starting a
      // new one (single-flight). Every concurrent waiter awaits the SAME future
      // and so observes the SAME tri-state outcome — so a transient failure
      // never logs out one waiter while another retries.
      final refreshFuture = _refreshFuture ??= _refreshToken(storedRefreshToken);
      final result = await refreshFuture;

      switch (result) {
        case _RefreshOk(token: final newAccessToken):
          // Retry the original request, bumping the attempt counter.
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
        case _RefreshAuthDead():
          // Refresh endpoint returned HTTP 401 — the refresh token is genuinely
          // invalid/expired. This is the ONLY refresh-path logout trigger.
          await _clearSessionAndRedirect();
          return handler.next(err);
        case _RefreshTransient():
          // 5XX / 429 / timeout / network — upstream is down or rate-limited.
          // Keep the session; surface the original error without teardown.
          return handler.next(err);
      }
    } catch (_) {
      // Defensive: an unexpected error retrying the resolved request must not
      // wipe the session (the refresh itself already succeeded).
      return handler.next(err);
    }
  }

  /// Performs the actual refresh request, saves the new tokens on success, and
  /// resets the future when finished. Returns a tri-state result so callers can
  /// distinguish a genuinely-dead refresh token (HTTP 401 → logout) from a
  /// transient upstream failure (5XX / 429 / timeout / network → keep session).
  Future<_RefreshResult> _refreshToken(String storedRefreshToken) async {
    try {
      // Use a separate Dio instance specifically for refresh to bypass
      // interceptors and avoid circular loops. validateStatus lets us read the
      // status code instead of having Dio throw, so a 401 vs 5XX is classified
      // explicitly rather than collapsing both into a thrown DioException.
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          contentType: 'application/json',
          responseType: ResponseType.json,
          validateStatus: (_) => true,
        ),
      );

      final refreshResponse = await refreshDio.post(
        Endpoints.refreshToken,
        data: {'refreshToken': storedRefreshToken},
      );

      final status = refreshResponse.statusCode;

      // HTTP 401 == AUTH_DEAD on this backend (the Aqua Go refresh wrapper maps
      // a genuinely invalid/expired refresh token to 401). This is the only
      // status that means "log out".
      if (status == 401) {
        return const _RefreshAuthDead();
      }

      // Any non-2xx that is NOT 401 (5XX, 503, 429, 4xx-other) is TRANSIENT —
      // never log out on these.
      if (status == null || status < 200 || status >= 300) {
        return const _RefreshTransient();
      }

      // Accept both camelCase and snake_case keys to be defensive against server variations
      final data = refreshResponse.data as Map<String, dynamic>?;
      final newAccessToken =
          (data?['accessToken'] ?? data?['access_token']) as String?;
      final newRefreshToken =
          (data?['refreshToken'] ?? data?['refresh_token']) as String?;

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        // Persist the new tokens
        await SecureStorage.saveSecuredString(kAccessToken, newAccessToken);
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await SecureStorage.saveSecuredString(kRefreshToken, newRefreshToken);
        }
        return _RefreshOk(newAccessToken);
      }

      // 2xx but no usable token in the body — treat as transient, not auth-dead.
      return const _RefreshTransient();
    } on DioException catch (_) {
      // Timeout / connectionError / SocketException — transport failure, not an
      // auth failure. Keep the session.
      return const _RefreshTransient();
    } catch (_) {
      return const _RefreshTransient();
    } finally {
      // Reset the future so subsequent failures in the future can trigger a new refresh flow
      _refreshFuture = null;
    }
  }

  /// Wipes all local credentials and navigates to the login screen
  /// without requiring a BuildContext.
  Future<void> _clearSessionAndRedirect() async {
    // purgeLocalSession clears _cachedUser + currentUser notifier + tokens.
    await locator<AuthRepository>().purgeLocalSession();

    if (_isRedirecting) return;
    _isRedirecting = true;

    AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.login,
      (route) => false,
    );

    // Reset so a subsequent expiry (after re-login) can redirect again.
    _isRedirecting = false;
  }
}

/// Tri-state outcome of a token refresh. Lets the interceptor distinguish a
/// genuinely-dead refresh token (HTTP 401 → logout) from a transient upstream
/// failure (5XX / 429 / timeout / network → keep session, retry/offline).
sealed class _RefreshResult {
  const _RefreshResult();
}

/// Refresh succeeded; [token] is the new access token (already persisted).
class _RefreshOk extends _RefreshResult {
  const _RefreshOk(this.token);
  final String token;
}

/// Refresh endpoint returned HTTP 401 — the refresh token is invalid/expired.
/// The ONLY refresh-path condition that warrants logout.
class _RefreshAuthDead extends _RefreshResult {
  const _RefreshAuthDead();
}

/// Refresh failed for a non-auth reason (5XX / 503 / 429 / timeout / network /
/// 2xx-without-token). Session must be kept.
class _RefreshTransient extends _RefreshResult {
  const _RefreshTransient();
}
