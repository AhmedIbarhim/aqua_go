// ignore_for_file: constant_identifier_names

import 'package:easy_localization/easy_localization.dart';
import '../../../../generated/locale_keys.g.dart';

enum FaqsCategoriesEnum {
  booking,
  payment,
  quality,
  service,
  coverage;

  static FaqsCategoriesEnum fromString(String? val) {
    if (val == null) return FaqsCategoriesEnum.service;
    switch (val.toUpperCase()) {
      case 'BOOKING':
        return FaqsCategoriesEnum.booking;
      case 'PAYMENT':
        return FaqsCategoriesEnum.payment;
      case 'QUALITY':
        return FaqsCategoriesEnum.quality;
      case 'SERVICE':
        return FaqsCategoriesEnum.service;
      case 'COVERAGE':
        return FaqsCategoriesEnum.coverage;
      default:
        return FaqsCategoriesEnum.service;
    }
  }

  String get apiValue {
    switch (this) {
      case FaqsCategoriesEnum.booking:
        return 'BOOKING';
      case FaqsCategoriesEnum.payment:
        return 'PAYMENT';
      case FaqsCategoriesEnum.quality:
        return 'QUALITY';
      case FaqsCategoriesEnum.service:
        return 'SERVICE';
      case FaqsCategoriesEnum.coverage:
        return 'COVERAGE';
    }
  }

  String get localizedName {
    switch (this) {
      case FaqsCategoriesEnum.booking:
        return LocaleKeys.support_faq_categories_booking.tr();
      case FaqsCategoriesEnum.payment:
        return LocaleKeys.support_faq_categories_payment.tr();
      case FaqsCategoriesEnum.quality:
        return LocaleKeys.support_faq_categories_quality.tr();
      case FaqsCategoriesEnum.service:
        return LocaleKeys.support_faq_categories_service.tr();
      case FaqsCategoriesEnum.coverage:
        return LocaleKeys.support_faq_categories_coverage.tr();
    }
  }
}
