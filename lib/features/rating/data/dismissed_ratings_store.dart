import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';

/// Local memory of booking ids the user dismissed from the home rating popup
/// (AQG-160). A dismissed booking is never re-prompted on subsequent home
/// loads — this is a deliberate user decision, persisted in SharedPrefs so it
/// survives app restarts. Rated bookings naturally drop off the
/// `bookings/pending-rating` endpoint, so they need no entry here.
abstract class DismissedRatingsStore {
  static const String _key = 'kDismissedRatingBookingIds';

  static Set<String> all() {
    return CacheClient.getStringList(_key).toSet();
  }

  static bool isDismissed(String bookingId) {
    return all().contains(bookingId);
  }

  static Future<void> dismiss(String bookingId) async {
    if (bookingId.isEmpty) return;
    final ids = all()..add(bookingId);
    await CacheClient.setStringList(_key, ids.toList());
  }
}
