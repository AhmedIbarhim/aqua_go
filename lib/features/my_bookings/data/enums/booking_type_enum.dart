// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extentions.dart';

enum BookingType {
  SCHEDULED;

  static BookingType? fromString(String? val) {
    if (val == null) return null;
    return BookingType.values.firstWhere(
      (e) => e.name == val.toUpperCase(),
      orElse: () => BookingType.SCHEDULED,
    );
  }

  String toJson() => name;

  String getTypeName(BuildContext context) {
    switch (this) {
      case BookingType.SCHEDULED:
        return context.isAr ? 'مجدول' : 'Scheduled';
    }
  }

  String getTypeCode(BuildContext context) {
    switch (this) {
      case BookingType.SCHEDULED:
        return context.isAr ? 'SCHEDULED' : 'SCHEDULED';
    }
  }
}
