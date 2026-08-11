import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';

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
