import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extentions/locale_extension.dart';
import '../../../../core/extentions/context_extentions/theme_extension.dart';

enum GiftStatus {
  ISSUED, // created, pending delivery
  DELIVERED, // recipient notified
  DELIVERY_FAILED, // delivery failed
  REDEEMED, // recipient has created a booking
  CANCELLED, // sender cancelled pre-delivery
  EXPIRED; // validity elapsed

  static GiftStatus? fromString(String? val) {
    if (val == null) return null;
    final upperVal = val.toUpperCase().replaceAll(' ', '_');
    return GiftStatus.values.firstWhere(
      (e) => e.name == upperVal,
      orElse: () => GiftStatus.ISSUED,
    );
  }

  String toJson() => name;

  String getStatusText(BuildContext context) {
    switch (this) {
      case GiftStatus.ISSUED:
        return context.isEn ? "Not Yet Delivered" : "لم يتم التوصيل";
      case GiftStatus.DELIVERED:
        return context.isEn ? "Delivered" : "مستلمة";
      case GiftStatus.DELIVERY_FAILED:
        return context.isEn ? "Delivery Failed" : "فشل التوصيل";
      case GiftStatus.REDEEMED:
        return context.isEn ? "Used" : "تم الاستخدام";
      case GiftStatus.CANCELLED:
        return context.isEn ? "Cancelled" : "تم الإلغاء";
      case GiftStatus.EXPIRED:
        return context.isEn ? "Expired" : "منتهية";
    }
  }

  Color getStatusBg(BuildContext context) {
    switch (this) {
      case GiftStatus.ISSUED:
        return context.colors.warning;
      case GiftStatus.DELIVERED:
        return context.colors.primary;
      case GiftStatus.DELIVERY_FAILED:
        return context.colors.error;
      case GiftStatus.REDEEMED:
        return context.colors.successSecondry;
      case GiftStatus.CANCELLED:
        return context.colors.contentSecondaryLight;
      case GiftStatus.EXPIRED:
        return context.colors.contentDisabled;
    }
  }

  Color getStatusTextColor(BuildContext context) {
    switch (this) {
      case GiftStatus.ISSUED:
      case GiftStatus.DELIVERED:
        return Colors.black;
      case GiftStatus.DELIVERY_FAILED:
      case GiftStatus.REDEEMED:
      case GiftStatus.CANCELLED:
      case GiftStatus.EXPIRED:
        return Colors.white;
    }
  }
}
