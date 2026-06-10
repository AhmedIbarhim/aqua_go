// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';

enum BookingStatus {
  UNSCHEDULED,
  PENDING,
  ASSIGNED,
  ON_THE_WAY,
  ARRIVED,
  STARTED,
  COMPLETED,
  CANCELLED;

  static BookingStatus? fromString(String? val) {
    if (val == null) return null;
    final upperVal = val.toUpperCase().replaceAll(' ', '_');
    return BookingStatus.values.firstWhere(
      (e) => e.name == upperVal,
      orElse: () => BookingStatus.PENDING,
    );
  }

  String toJson() => name;

  String getStatusText(BuildContext context) {
    final isAr = context.isAr;
    switch (this) {
      case BookingStatus.UNSCHEDULED:
        return isAr ? 'غير مجدول' : 'Unscheduled';
      case BookingStatus.PENDING:
        return isAr ? 'قيد الانتظار' : 'Pending';
      case BookingStatus.ASSIGNED:
        return isAr ? 'تم تعيين العامل' : 'Biker Assigned';
      case BookingStatus.ON_THE_WAY:
        return isAr ? 'العامل في الطريق' : 'On the Way';
      case BookingStatus.ARRIVED:
        return isAr ? 'وصل العامل' : 'Biker Arrived';
      case BookingStatus.STARTED:
        return isAr ? 'بدأ الغسيل' : 'Washing Started';
      case BookingStatus.COMPLETED:
        return isAr ? 'مكتمل' : 'Completed';
      case BookingStatus.CANCELLED:
        return isAr ? 'ملغي' : 'Cancelled';
    }
  }

  Color getStatusBg(BuildContext context) {
    switch (this) {
      case BookingStatus.UNSCHEDULED:
        return Colors.grey.shade400;
      case BookingStatus.PENDING:
        return Colors.orange;
      case BookingStatus.ASSIGNED:
        return Colors.teal;
      case BookingStatus.ON_THE_WAY:
        return Colors.blueAccent;
      case BookingStatus.ARRIVED:
        return Colors.purple;
      case BookingStatus.STARTED:
        return Colors.blue;
      case BookingStatus.COMPLETED:
        return Colors.green;
      case BookingStatus.CANCELLED:
        return Colors.red;
    }
  }

  Color getStatusTextColor(BuildContext context) {
    switch (this) {
      case BookingStatus.UNSCHEDULED:
      case BookingStatus.PENDING:
      case BookingStatus.ASSIGNED:
      case BookingStatus.ON_THE_WAY:
      case BookingStatus.ARRIVED:
      case BookingStatus.STARTED:
      case BookingStatus.COMPLETED:
      case BookingStatus.CANCELLED:
        return Colors.white;
    }
  }
}
