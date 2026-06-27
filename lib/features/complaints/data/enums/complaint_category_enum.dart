import 'package:easy_localization/easy_localization.dart';

import '../../../../generated/locale_keys.g.dart';

enum ComplaintCategory {
  serviceQuality,
  missedAppointment,
  propertyDamage,
  workerBehavior,
  billing,
  other;

  static ComplaintCategory fromString(String? val) {
    if (val == null) return ComplaintCategory.other;
    switch (val.toUpperCase()) {
      case 'SERVICE_QUALITY':
        return ComplaintCategory.serviceQuality;
      case 'MISSED_APPOINTMENT':
        return ComplaintCategory.missedAppointment;
      case 'PROPERTY_DAMAGE':
        return ComplaintCategory.propertyDamage;
      case 'WORKER_BEHAVIOR':
        return ComplaintCategory.workerBehavior;
      case 'BILLING':
        return ComplaintCategory.billing;
      case 'OTHER':
      default:
        return ComplaintCategory.other;
    }
  }

  String get apiValue {
    switch (this) {
      case ComplaintCategory.serviceQuality:
        return 'SERVICE_QUALITY';
      case ComplaintCategory.missedAppointment:
        return 'MISSED_APPOINTMENT';
      case ComplaintCategory.propertyDamage:
        return 'PROPERTY_DAMAGE';
      case ComplaintCategory.workerBehavior:
        return 'WORKER_BEHAVIOR';
      case ComplaintCategory.billing:
        return 'BILLING';
      case ComplaintCategory.other:
        return 'OTHER';
    }
  }

  String get translationKey {
    switch (this) {
      case ComplaintCategory.serviceQuality:
        return LocaleKeys.bookings_complaint_types_poor_wash_quality;
      case ComplaintCategory.missedAppointment:
        return LocaleKeys.bookings_complaint_types_arrival_delay;
      case ComplaintCategory.propertyDamage:
        return LocaleKeys.bookings_complaint_types_car_damage;
      case ComplaintCategory.workerBehavior:
        return LocaleKeys.bookings_complaint_types_worker_behavior;
      case ComplaintCategory.billing:
        return LocaleKeys.bookings_complaint_types_billing_issue;
      case ComplaintCategory.other:
        return LocaleKeys.bookings_complaint_types_other_type;
    }
  }

  static ComplaintCategory categoryFromTranslation(String text) {
    final lowerText = text.toLowerCase().trim();
    if (lowerText ==
            LocaleKeys.bookings_complaint_types_poor_wash_quality
                .tr()
                .toLowerCase()
                .trim() ||
        lowerText ==
            LocaleKeys.bookings_complaint_types_wrong_service
                .tr()
                .toLowerCase()
                .trim()) {
      return ComplaintCategory.serviceQuality;
    }
    if (lowerText ==
        LocaleKeys.bookings_complaint_types_arrival_delay
            .tr()
            .toLowerCase()
            .trim()) {
      return ComplaintCategory.missedAppointment;
    }
    if (lowerText ==
        LocaleKeys.bookings_complaint_types_worker_behavior
            .tr()
            .toLowerCase()
            .trim()) {
      return ComplaintCategory.workerBehavior;
    }
    if (lowerText ==
            LocaleKeys.bookings_complaint_types_car_damage
                .tr()
                .toLowerCase()
                .trim() ||
        lowerText ==
            LocaleKeys.bookings_complaint_types_safety_incident
                .tr()
                .toLowerCase()
                .trim()) {
      return ComplaintCategory.propertyDamage;
    }
    if (lowerText ==
        LocaleKeys.bookings_complaint_types_billing_issue
            .tr()
            .toLowerCase()
            .trim()) {
      return ComplaintCategory.billing;
    }
    return ComplaintCategory.other;
  }
}
