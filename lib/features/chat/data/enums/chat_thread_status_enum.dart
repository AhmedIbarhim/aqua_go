import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../generated/locale_keys.g.dart';

enum ChatThreadStatus {
  open,
  assigned,
  resolved,
  closed;

  static ChatThreadStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'ASSIGNED':
        return ChatThreadStatus.assigned;
      case 'RESOLVED':
        return ChatThreadStatus.resolved;
      case 'CLOSED':
        return ChatThreadStatus.closed;
      case 'OPEN':
      default:
        return ChatThreadStatus.open;
    }
  }

  String get originalValue {
    switch (this) {
      case ChatThreadStatus.open:
        return 'OPEN';
      case ChatThreadStatus.assigned:
        return 'ASSIGNED';
      case ChatThreadStatus.resolved:
        return 'RESOLVED';
      case ChatThreadStatus.closed:
        return 'CLOSED';
    }
  }

  bool get isReopenable =>
      this == ChatThreadStatus.resolved || this == ChatThreadStatus.closed;

  String get translationKey {
    switch (this) {
      case ChatThreadStatus.open:
        return LocaleKeys.chat_status_open;
      case ChatThreadStatus.assigned:
        return LocaleKeys.chat_status_assigned;
      case ChatThreadStatus.resolved:
        return LocaleKeys.chat_status_resolved;
      case ChatThreadStatus.closed:
        return LocaleKeys.chat_status_closed;
    }
  }

  Color getBgColor(BuildContext context) {
    switch (this) {
      case ChatThreadStatus.open:
        return context.colors.primary;
      case ChatThreadStatus.assigned:
        return context.colors.info;
      case ChatThreadStatus.resolved:
        return context.colors.successSecondry;
      case ChatThreadStatus.closed:
        return context.colors.defaultSubtle;
    }
  }

  Color getTextColor(BuildContext context) {
    switch (this) {
      case ChatThreadStatus.open:
        return darkAppColors.themeColor;
      case ChatThreadStatus.assigned:
        return darkAppColors.themeOpositeColor;
      case ChatThreadStatus.resolved:
        return darkAppColors.themeColor;
      case ChatThreadStatus.closed:
        return context.colors.textPrimary;
    }
  }
}
