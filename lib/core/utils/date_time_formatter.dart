import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show TimeOfDay;

/// The app's single date/time DISPLAY formatter.
///
/// Nothing parses these strings back — wire values are built from the source
/// [DateTime] via `saudi_wire_format.dart`.
///
/// **Locale source: [Intl.defaultLocale].** `launch_app` pins it to the app's
/// language at boot and `LanguageCubit._applyLocale` re-pins it on every
/// language change, so it always tracks the language the customer picked
/// in-app. It is read here rather than `context.isAr` because the model getters
/// these formatters serve (`formattedDateTime`) have no `BuildContext`, and
/// threading one through the data layer to format a date would be worse than
/// the bug. `Intl.getCurrentLocale()` is deliberately NOT used: it falls back
/// to the device OS locale, which is the defect this module exists to prevent.
///
/// The app boots Arabic-first (`fallbackLocale: ar`), so an unpinned
/// `Intl.defaultLocale` resolves to `ar` rather than silently to the device.

String get _locale => Intl.defaultLocale ?? 'ar';

/// Clock time, e.g. `2:00 PM` / `٢:٠٠ م` — locale's own 12/24-hour convention
/// and meridiem markers.
String formatClockTime(DateTime time) => DateFormat.jm(_locale).format(time);

/// Clock time for a time-only pick, e.g. `9:00 PM` / `٩:٠٠ م`.
///
/// A picker button is the one place a time exists before a date does. The date
/// passed through is inert — [formatClockTime] reads the time fields only —
/// and `MaterialLocalizations.formatTimeOfDay` is deliberately not used: its
/// output is a LABEL, and the gift flow once parsed one back into a wire value.
String formatPickedTime(TimeOfDay time) =>
    formatClockTime(DateTime(2000, 1, 1, time.hour, time.minute));

/// Numeric date in the locale's own field order, e.g. `7/23/2026` / `٢٣‏/٧‏/٢٠٢٦`.
String formatShortDate(DateTime date) => DateFormat.yMd(_locale).format(date);

/// Date and time together, e.g. `7/23/2026 - 2:00 PM`.
String formatDateAndTime(DateTime dateTime) =>
    '${formatShortDate(dateTime)} - ${formatClockTime(dateTime)}';

/// Month and year, e.g. `July, 2026` / `يوليو، 2026`.
String formatMonthYear(DateTime date) =>
    DateFormat('MMMM, yyyy', _locale).format(date);

/// Full weekday name, e.g. `Thursday` / `الخميس`.
String formatWeekday(DateTime date) => DateFormat('EEEE', _locale).format(date);

/// Day of the month with no padding, e.g. `23`.
String formatDayOfMonth(DateTime date) => DateFormat('d', _locale).format(date);

/// Fixed day-first numeric date, e.g. `23 - 07 - 2026`.
///
/// Used for package/subscription expiry, where the two surfaces previously
/// disagreed with each other (`dd - MM - yyyy` vs `yyyy - MM - dd`) on the same
/// value. The field order is deliberately fixed rather than locale-driven —
/// only the digits follow the locale.
String formatNumericDate(DateTime date) =>
    DateFormat('dd - MM - yyyy', _locale).format(date);

/// Date of birth as shown in the profile form, e.g. `23/7/2026`.
String formatDateOfBirth(DateTime date) =>
    DateFormat('d/M/y', _locale).format(date);
