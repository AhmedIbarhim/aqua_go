// Shared notification deep-link routing for the customer app.
//
// ONE routing function serves both surfaces:
//   1. In-app inbox tap (NotificationCard) — routes on the inbox record's
//      (targetType, targetId).
//   2. Push tap (FCM data payload) — routes on the same (targetType, targetId)
//      pair the backend now ships in the FCM `data` block.
//
// Cold-start safety: a push tap on a killed app (getInitialMessage /
// getNotificationAppLaunchDetails) cannot navigate immediately — the router,
// auth gate and home shell are not mounted yet. Such taps are parked in
// [pendingDeepLink] and consumed once after the splash/auth gate lands the
// user on the home layout (see consumePendingDeepLink()).
//
// R-15: targetId is a non-PII UUID. Never log payload contents; never add
// name/phone/plate/coordinates to the data block.
import 'package:flutter/widgets.dart';

import '../../core/route/app_router.dart';
import '../../core/route/routes.dart';
import '../complaints/presentation/views/complaint_details_view.dart';
import '../my_bookings/data/models/booking_summary_model.dart';
import '../my_bookings/presentation/views/my_booking_deatails_view.dart';

/// A deep-link target parsed from either an inbox record or an FCM data block.
class NotificationTarget {
  final String targetType; // BOOKING | COMPLAINT | SUBSCRIPTION
  final String targetId;

  const NotificationTarget({required this.targetType, required this.targetId});

  String get key => '$targetType:$targetId';

  /// Builds a target from an FCM data payload (a `Map<String, dynamic>` whose
  /// values are Strings). Returns null when the routing pair is absent.
  static NotificationTarget? fromData(Map<String, dynamic> data) {
    final targetType = data['targetType']?.toString();
    final targetId = data['targetId']?.toString();
    if (targetType == null ||
        targetType.isEmpty ||
        targetId == null ||
        targetId.isEmpty) {
      return null;
    }
    return NotificationTarget(targetType: targetType, targetId: targetId);
  }
}

/// A killed-app push tap parked until the app + auth are ready. Consumed once
/// by [consumePendingDeepLink] after the home shell mounts; nulled on consume
/// to guard against hot-restart replay.
NotificationTarget? pendingDeepLink;

/// Last (targetType:targetId) routed within this app launch. Guards against
/// double-navigation when more than one FCM entry point reports the same tap.
String? _lastRoutedKey;

/// Routes to the page for [target] using the existing global navigator handle
/// ([AppRouter.navigatorKey]) — no BuildContext required, safe for out-of-tree
/// callers (push-tap handlers). Returns true if a route was pushed.
///
/// Unknown / unsupported targetType is a graceful no-op (never throws).
bool routeForNotification(NotificationTarget target, {bool dedupe = true}) {
  if (dedupe && _lastRoutedKey == target.key) return false;

  final navigator = AppRouter.navigatorKey.currentState;
  if (navigator == null) return false;

  switch (target.targetType) {
    case 'BOOKING':
      navigator.pushNamed(
        Routes.myBookingDetails,
        arguments: MyBookingDetailsArgs(
          booking: BookingSummaryModel(id: target.targetId),
        ),
      );
      _lastRoutedKey = target.key;
      return true;
    case 'COMPLAINT':
      navigator.pushNamed(
        Routes.complaintDetails,
        arguments: ComplaintDetailsArgs(complaintId: target.targetId),
      );
      _lastRoutedKey = target.key;
      return true;
    case 'SUBSCRIPTION':
      // No per-subscription detail route exists today; land on the list view.
      navigator.pushNamed(Routes.mySubscribedPackages);
      _lastRoutedKey = target.key;
      return true;
    default:
      // Unknown targetType (e.g. SYSTEM) — graceful no-op.
      return false;
  }
}

/// Routes a notification by its raw inbox/payload routing fields. Used by the
/// in-app inbox tap (NotificationCard). No-op when the pair is incomplete.
bool routeForNotificationFields(String? targetType, String? targetId) {
  if (targetType == null ||
      targetType.isEmpty ||
      targetId == null ||
      targetId.isEmpty) {
    return false;
  }
  return routeForNotification(
    NotificationTarget(targetType: targetType, targetId: targetId),
    // In-app taps must always navigate, even to a target a push already
    // opened earlier this launch.
    dedupe: false,
  );
}

/// Handles an FCM tap from any of the three entry points.
///
/// - When [appReady] (background / foreground-reshown tap, app already running
///   and authed): route immediately via the global handle.
/// - When NOT [appReady] (killed-app cold start): park the target in
///   [pendingDeepLink]; it is consumed after the splash/auth gate.
///
/// R-15: never log [data] contents.
void handleNotificationTap(Map<String, dynamic> data, {required bool appReady}) {
  final target = NotificationTarget.fromData(data);
  if (target == null) return; // no routing pair (e.g. SYSTEM push) — no-op.

  if (appReady) {
    final routed = routeForNotification(target);
    // If the navigator was not mounted yet (race), fall back to parking it.
    if (!routed) pendingDeepLink = target;
  } else {
    pendingDeepLink = target;
  }
}

/// Consumes a parked cold-start deep-link exactly once, after the auth gate
/// confirms an authenticated session and the home shell is mounted. Safe to
/// call unconditionally — it is a no-op when nothing is parked.
///
/// Defers to the end of the frame so the just-pushed home route is mounted
/// before the deep-link route is pushed on top of it.
void consumePendingDeepLink() {
  final target = pendingDeepLink;
  if (target == null) return;
  pendingDeepLink = null;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    routeForNotification(target);
  });
}
