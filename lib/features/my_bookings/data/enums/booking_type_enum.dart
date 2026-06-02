// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extentions.dart';

enum BookingType {
  ON_DEMAND,
  SCHEDULED;

  static BookingType? fromString(String? val) {
    if (val == null) return null;
    return BookingType.values.firstWhere(
      (e) => e.name == val.toUpperCase(),
      orElse: () => BookingType.ON_DEMAND,
    );
  }

  String toJson() => name;

  String getTypeName(BuildContext context) {
    final isAr = context.isAr;
    switch (this) {
      case BookingType.ON_DEMAND:
        return isAr ? 'عند الطلب' : 'On Demand';
      case BookingType.SCHEDULED:
        return isAr ? 'مجدول' : 'Scheduled';
    }
  }

  String getTypeCode(BuildContext context) {
    final isAr = context.isAr;
    switch (this) {
      case BookingType.ON_DEMAND:
        return isAr ? 'ON_DEMAND' : 'ON_DEMAND';
      case BookingType.SCHEDULED:
        return isAr ? 'SCHEDULED' : 'SCHEDULED';
    }
  }
}
