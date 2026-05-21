class DayTimeModel {
  final DateTime date;
  final String rawTime;

  DayTimeModel({required this.date, required this.rawTime});

  /// Formats the raw time string (e.g. "9:00 صباحاً" or "1:00 ظهراً")
  /// into a standard 24-hour time format with proper padding (e.g. "09:00" or "13:00").
  String get formattedTime {
    final cleanStr = rawTime.trim();

    // Extract the time part (e.g., "9:00" from "9:00 صباحاً")
    final timeParts = cleanStr.split(' ');
    final raw = timeParts.isNotEmpty ? timeParts.first : cleanStr;

    final colonParts = raw.split(':');
    if (colonParts.length < 2) {
      return "00:00";
    }

    int hour = int.tryParse(colonParts[0]) ?? 0;
    int minute = int.tryParse(colonParts[1]) ?? 0;

    final isPM =
        cleanStr.contains('مساءً') ||
        cleanStr.contains('PM') ||
        cleanStr.contains('pm') ||
        cleanStr.contains('ظهراً');

    final isAM =
        cleanStr.contains('صباحاً') ||
        cleanStr.contains('AM') ||
        cleanStr.contains('am');

    if (isPM) {
      if (hour < 12) {
        hour += 12;
      }
    } else if (isAM) {
      if (hour == 12) {
        hour = 0;
      }
    }

    final String formattedHour = hour.toString().padLeft(2, '0');
    final String formattedMin = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMin';
  }

  /// Converts the date and time to standard ISO-8601 string format (e.g. "2026-05-22T09:00:00Z").
  String toScheduledAtString() {
    final String formattedMonth = date.month.toString().padLeft(2, '0');
    final String formattedDay = date.day.toString().padLeft(2, '0');
    return '${date.year}-$formattedMonth-${formattedDay}T$formattedTime:00Z';
  }
}
