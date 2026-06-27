import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extentions/theme_extension.dart';
import '../../../../generated/locale_keys.g.dart';

enum ComplaintStatus {
  open,
  closed,
  resolved,
  pending,
  rejected;

  static ComplaintStatus fromString(String? status) {
    if (status == null) return ComplaintStatus.open;
    switch (status.toUpperCase()) {
      case 'OPEN':
        return ComplaintStatus.open;
      case 'CLOSED':
        return ComplaintStatus.closed;
      case 'RESOLVED':
        return ComplaintStatus.resolved;
      case 'REJECTED':
        return ComplaintStatus.rejected;
      case 'UNDER_REVIEW':
      case 'AWAITING_CUSTOMER':
      case 'PENDING':
      default:
        return ComplaintStatus.pending;
    }
  }

  String get originalValue {
    switch (this) {
      case ComplaintStatus.open:
        return 'OPEN';
      case ComplaintStatus.closed:
        return 'CLOSED';
      case ComplaintStatus.resolved:
        return 'RESOLVED';
      case ComplaintStatus.pending:
        return 'UNDER_REVIEW';
      case ComplaintStatus.rejected:
        return 'REJECTED';
    }
  }

  String get translationKey {
    switch (this) {
      case ComplaintStatus.open:
        return LocaleKeys.complaint_status_open;
      case ComplaintStatus.closed:
        return LocaleKeys.complaint_status_closed;
      case ComplaintStatus.resolved:
        return LocaleKeys.complaint_status_resolved;
      case ComplaintStatus.pending:
        return LocaleKeys.complaint_status_pending;
      case ComplaintStatus.rejected:
        return LocaleKeys.complaint_status_rejected;
    }
  }

  Color getBgColor(BuildContext context) {
    return context.colors.primary;
    // switch (this) {
    //   case ComplaintStatus.open:
    //     return context.colors.primary;
    //   case ComplaintStatus.closed:
    //     return context.colors.errorLight;
    //   case ComplaintStatus.resolved:
    //     return context.colors.successLight;
    //   case ComplaintStatus.pending:
    //     return context.colors.defaultSubtle;
    //   case ComplaintStatus.rejected:
    //     return context.colors.errorLight;
    // }
  }

  Color getTextColor(BuildContext context) {
    return Colors.black;
    // switch (this) {
    //   case ComplaintStatus.open:
    //     return darkAppColors.themeColor;
    //   case ComplaintStatus.closed:
    //     return darkAppColors.themeOpositeColor;
    //   case ComplaintStatus.resolved:
    //     return darkAppColors.themeColor;
    //   case ComplaintStatus.pending:
    //     return darkAppColors.themeOpositeColor;
    //   case ComplaintStatus.rejected:
    //     return darkAppColors.themeOpositeColor;
    // }
  }
}
