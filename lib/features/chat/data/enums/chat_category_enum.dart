import '../../../../generated/locale_keys.g.dart';

/// Support-ticket category. WORKER is really for the separate CUSTOMER_WORKER
/// thread kind, so it is omitted from the customer support picker
/// ([pickerCategories]). GENERAL is the default.
enum ChatCategory {
  bookingIssue,
  payment,
  account,
  worker,
  general;

  static ChatCategory fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'BOOKING_ISSUE':
        return ChatCategory.bookingIssue;
      case 'PAYMENT':
        return ChatCategory.payment;
      case 'ACCOUNT':
        return ChatCategory.account;
      case 'WORKER':
        return ChatCategory.worker;
      case 'GENERAL':
      default:
        return ChatCategory.general;
    }
  }

  String get originalValue {
    switch (this) {
      case ChatCategory.bookingIssue:
        return 'BOOKING_ISSUE';
      case ChatCategory.payment:
        return 'PAYMENT';
      case ChatCategory.account:
        return 'ACCOUNT';
      case ChatCategory.worker:
        return 'WORKER';
      case ChatCategory.general:
        return 'GENERAL';
    }
  }

  String get translationKey {
    switch (this) {
      case ChatCategory.bookingIssue:
        return LocaleKeys.chat_category_booking_issue;
      case ChatCategory.payment:
        return LocaleKeys.chat_category_payment;
      case ChatCategory.account:
        return LocaleKeys.chat_category_account;
      case ChatCategory.worker:
        return LocaleKeys.chat_category_worker;
      case ChatCategory.general:
        return LocaleKeys.chat_category_general;
    }
  }

  /// Categories surfaced in the customer "new ticket" picker (WORKER excluded).
  static const List<ChatCategory> pickerCategories = [
    ChatCategory.bookingIssue,
    ChatCategory.payment,
    ChatCategory.account,
    ChatCategory.general,
  ];
}
