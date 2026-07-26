import 'package:easy_localization/easy_localization.dart';

/// Display formatting for booking dates and times.
///
/// These produce **display strings only**. Nothing parses them back — the wire
/// value is built from the slot's [DateTime] via `saudi_wire_format.dart`.
///
/// Every formatter is given an explicit locale. A bare `DateFormat(...)`
/// resolves `Intl.defaultLocale`, which without an explicit pin is the phone's
/// OS locale rather than the language the customer picked in the app.

String _localeTag({required bool isArabic}) => isArabic ? 'ar' : 'en';

/// A slot's start time, e.g. `2:00 PM` / `2:00 مساءً`.
String formatSlotTime(DateTime time, {required bool isArabic}) {
  if (isArabic) {
    final minStr = time.minute.toString().padLeft(2, '0');

    final String period;
    int displayHour = time.hour;
    if (time.hour >= 12) {
      period = time.hour == 12 ? 'ظهراً' : 'مساءً';
      if (time.hour > 12) displayHour = time.hour - 12;
    } else {
      period = 'صباحاً';
      if (time.hour == 0) displayHour = 12;
    }

    return '$displayHour:$minStr $period';
  }
  return DateFormat('h:mm a', _localeTag(isArabic: isArabic)).format(time);
}

/// A slot's calendar date in the locale's own field order.
String formatSlotDate(DateTime date, {required bool isArabic}) =>
    DateFormat.yMd(_localeTag(isArabic: isArabic)).format(date);

/// A slot's date and time together, e.g. `7/23/2026 - 2:00 PM`.
String formatSlotDateTime(DateTime dateTime, {required bool isArabic}) =>
    '${formatSlotDate(dateTime, isArabic: isArabic)}'
    ' - ${formatSlotTime(dateTime, isArabic: isArabic)}';
