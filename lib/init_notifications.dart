// Mirrored from worker-mobile/lib/init_notifications.dart with two deltas:
// 1. Android channel id 'aqua_go_customer' (not 'aqua_go_worker').
// 2. No foregroundPushStream consumer wired — stream kept for future use.
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

bool didInitNotifications = false;

// Broadcast stream that fires whenever a push arrives while the app is
// foregrounded (FirebaseMessaging.onMessage). Kept in parallel with the worker
// pattern; no consumer is wired in Phase 1.
// Pattern mirrors worker-mobile/init_notifications.dart.
final foregroundPushStream = StreamController<void>.broadcast();

Future<void> initNotifications() async {
  if (didInitNotifications) return;
  didInitNotifications = true;
  FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    handleNotificationTap(message.data);
  });
  final fcmMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (fcmMessage != null) {
    handleNotificationTap(fcmMessage.data);
  }
  final message =
      await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
  final payload = message?.notificationResponse?.payload;
  if (payload != null) {
    handleNotificationTap(jsonDecode(payload));
  }
  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings('ic_stat_name'),
    iOS: DarwinInitializationSettings(),
  );
  FlutterLocalNotificationsPlugin().initialize(
    settings: initSettings,
    onDidReceiveNotificationResponse: (details) {
      if (details.payload == null) return;
      final data = jsonDecode(details.payload!);
      handleNotificationTap(data);
    },
  );
  FirebaseMessaging.onMessage.listen((event) async {
    // Localization model: the backend server-renders title/body in the locale
    // registered on this device's FCM token. The client keeps that locale
    // current by re-registering the token on every locale change (see
    // LanguageCubit -> syncDeviceToken). So `event.notification.title/body`
    // already arrive in the user's current language — render them directly.
    // No on-device data-payload parsing is needed for tray text.
    await FlutterLocalNotificationsPlugin().show(
      id: Random().nextInt(214748364),
      title: event.notification?.title ?? '-',
      body: event.notification?.body ?? '-',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'aqua_go_customer',
          'Notifications',
          priority: Priority.high,
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.active,
        ),
      ),
      payload: event.data.isEmpty ? null : jsonEncode(event.data),
    );
    foregroundPushStream.add(null);
  });
}

/// Fires from all three FCM entry points (onMessageOpenedApp,
/// getInitialMessage, local-notif onDidReceiveNotificationResponse).
///
/// R-15: never log payload contents (may carry ids).
void handleNotificationTap(Map<String, dynamic> payload) {
  // No deep-link routing wired in Phase 1.
}
