import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show TimeOfDay;

String get _locale => Intl.defaultLocale ?? 'ar';

String formatClockTime(DateTime time) => DateFormat.jm(_locale).format(time);

String formatPickedTime(TimeOfDay time) =>
    formatClockTime(DateTime(2000, 1, 1, time.hour, time.minute));

String formatShortDate(DateTime date) =>
    DateFormat('d/M/y', _locale).format(date);

String formatDateAndTime(DateTime dateTime) =>
    '${formatShortDate(dateTime)} - ${formatClockTime(dateTime)}';

String formatMonthYear(DateTime date) =>
    DateFormat('MMMM, yyyy', _locale).format(date);

String formatWeekday(DateTime date) => DateFormat('EEEE', _locale).format(date);

String formatDayOfMonth(DateTime date) => DateFormat('d', _locale).format(date);

String formatNumericDate(DateTime date) =>
    DateFormat('dd - MM - yyyy', _locale).format(date);

String formatDateOfBirth(DateTime date) =>
    DateFormat('d/M/y', _locale).format(date);
