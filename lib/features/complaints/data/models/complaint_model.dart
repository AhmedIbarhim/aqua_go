import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extentions.dart';

enum ComplaintStatus {
  open,
  closed,
  resolved,
  pending;

  String get translationKey {
    switch (this) {
      case ComplaintStatus.open:
        return LocaleKeys.complaint_status_open.tr();
      case ComplaintStatus.closed:
        return LocaleKeys.complaint_status_closed.tr();
      case ComplaintStatus.resolved:
        return LocaleKeys.complaint_status_resolved.tr();
      case ComplaintStatus.pending:
        return LocaleKeys.complaint_status_pending.tr();
    }
  }

  Color getBgColor(BuildContext context) {
    switch (this) {
      case ComplaintStatus.open:
        return context.colors.primary;
      case ComplaintStatus.closed:
        return context.colors.errorLight;
      case ComplaintStatus.resolved:
        return context.colors.successLight;
      case ComplaintStatus.pending:
        return context.colors.defaultSubtle;
    }
  }

  Color getTextColor(BuildContext context) {
    switch (this) {
      case ComplaintStatus.open:
        return darkAppColors.themeColor;
      case ComplaintStatus.closed:
        return darkAppColors.themeOpositeColor;
      case ComplaintStatus.resolved:
        return darkAppColors.themeColor;
      case ComplaintStatus.pending:
        return darkAppColors.themeOpositeColor;
    }
  }
}

class ComplaintModel {
  final String id;
  final String dateAr;
  final String dateEn;
  final String timeAr;
  final String timeEn;
  final ComplaintStatus status;
  final String detailsAr;
  final String detailsEn;
  final String bookingId;

  const ComplaintModel({
    required this.id,
    required this.dateAr,
    required this.dateEn,
    required this.timeAr,
    required this.timeEn,
    required this.status,
    required this.detailsAr,
    required this.detailsEn,
    required this.bookingId,
  });

  String getDate(BuildContext context) => context.isAr ? dateAr : dateEn;
  String getTime(BuildContext context) => context.isAr ? timeAr : timeEn;
  String getDetails(BuildContext context) =>
      context.isAr ? detailsAr : detailsEn;
}
