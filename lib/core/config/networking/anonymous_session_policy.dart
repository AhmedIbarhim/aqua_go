/// `RequestOptions.extra` flag marking a call that is legitimately made while
/// signed out — the public, `permitAll` surfaces such as `GET /api/public/offers`.
/// A request carrying this flag must never trigger a session teardown.
///
/// This is the ONLY declaration of this constant in the app. Do not re-declare
/// it in `lib/core/constants.dart`: `refresh_token_interceptor.dart` imports
/// both files, so a second declaration is an `ambiguous_import` error, and two
/// different literals would silently break the guard.
///
/// The predicate that READS this flag — `shouldTearDownTokenlessSession` — is
/// appended to this same file by the guest-path task.
const String kAllowAnonymous = 'allowAnonymous';

/// Whether a Dio error on a request made with NO access token and NO refresh
/// token should wipe local credentials and bounce the user to the login screen.
///
/// Historically this was unconditionally `true`, which meant a browsing guest
/// was thrown to login by any 404, 5xx, timeout or offline blip. Teardown is
/// now the narrow case: an HTTP 401 from an endpoint that was NOT declared
/// anonymous — i.e. the app genuinely asked for protected data with no
/// credentials, so a login is the only way forward.
bool shouldTearDownTokenlessSession({
  required bool allowAnonymous,
  required int? statusCode,
}) {
  if (allowAnonymous) return false;
  return statusCode == 401;
}
