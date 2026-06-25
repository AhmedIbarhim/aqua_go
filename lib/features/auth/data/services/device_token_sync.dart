import 'dart:convert';
import 'dart:io';

import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/features/auth/data/repos/device_repository.dart';
import 'package:aqua_go/core/helpers/fetch_user_data_helper.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';

const String kRegisteredDeviceId = 'kRegisteredDeviceId';

bool _tokenRefreshListenerAttached = false;

/// Resolves the app locale code ('ar' or 'en') from CacheClient without
/// a BuildContext — mirrors the logic in main.dart.
String _resolveLocaleCode() {
  final lang = CacheClient.getString(kLanguage, defaultValue: kArabicLang);
  return lang == kArabicLang ? 'ar' : 'en';
}

/// Registers (or refreshes) the FCM token with the backend device registry.
///
/// Safe to call fire-and-forget; all network failures are swallowed so
/// login/logout are never broken by a push-registration hiccup.
Future<void> syncDeviceToken() async {
  if (!FetchUserData.getIsLoggedIn()) return;

  // Attach the token-refresh listener exactly once per process lifetime.
  if (!_tokenRefreshListenerAttached) {
    _tokenRefreshListenerAttached = true;
    FirebaseMessaging.instance.onTokenRefresh.listen((_) => syncDeviceToken());
  }

  try {
    // On iOS the APNs token must be available before getToken() works.
    // Retry a few times with a short delay (known iOS pitfall).
    if (Platform.isIOS) {
      String? apnsToken;
      for (int i = 0; i < 5; i++) {
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null) break;
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if (apnsToken == null) return;
    }

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) return;

    final customerId = FetchUserData.getUserId() ?? 'self';
    final idempotencyKey =
        'customer-device-register:$customerId:'
        '${sha256.convert(utf8.encode(fcmToken))}';

    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = packageInfo.version;
    final platform = Platform.isAndroid ? 'ANDROID' : 'IOS';
    final locale = _resolveLocaleCode();

    final result = await locator<DeviceRepository>().registerDevice(
      fcmToken: fcmToken,
      platform: platform,
      appVersion: appVersion,
      locale: locale,
      idempotencyKey: idempotencyKey,
    );

    result.fold(
      (_) {/* silently ignore registration failures */},
      (device) async {
        await CacheClient.setString(kRegisteredDeviceId, device.id);
      },
    );
  } catch (_) {
    // Never let a push-registration failure surface to the caller.
  }
}

/// Removes the registered device from the backend and clears the locally
/// stored id. Called from logout and account-deletion paths.
Future<void> deregisterStoredDevice() async {
  try {
    final deviceId = CacheClient.getString(kRegisteredDeviceId);
    if (deviceId.isEmpty) return;
    await locator<DeviceRepository>().deregisterDevice(deviceId);
    await CacheClient.removeString(kRegisteredDeviceId);
  } catch (_) {
    // Swallow — logout must succeed even if deregistration fails.
    await CacheClient.removeString(kRegisteredDeviceId);
  }
}
