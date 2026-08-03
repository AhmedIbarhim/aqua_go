// Wire-aligned UPPER_CASE values (PAID / NOT_REQUIRED / …) intentionally
// mirror the backend `paymentStatus` tokens, so the standard lowerCamelCase
// lint is disabled for this enum.
// ignore_for_file: constant_identifier_names

/// Booking / wash payment status, as returned by the backend on the
/// `paymentStatus` wire field under the Moyasar immediate-capture model.
///
/// Collapsed set (spec §6.1): the card is charged in full at create
/// (`PAID`) and subscription-covered washes are `NOT_REQUIRED`. There is no
/// reversal state — refunds were removed platform-wide on 2026-07-29, so a
/// booking that was paid and then cancelled stays `PAID`. `fromString`
/// returns null for any other token, including the retired `REFUNDED` /
/// `PARTIALLY_REFUNDED`, so an old payload never throws on read.
///
/// NOTE: the Moyasar SDK ships its own unrelated `PaymentStatus` enum
/// (paid/failed/initiated) for the on-device purchase result. This enum is
/// the domain booking status and must NOT be imported into any file that
/// imports `package:moyasar/moyasar.dart` without an import prefix.
enum PaymentStatus {
  PAID,
  NOT_REQUIRED;

  static PaymentStatus? fromString(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'PAID':
        return PaymentStatus.PAID;
      case 'NOT_REQUIRED':
        return PaymentStatus.NOT_REQUIRED;
      default:
        return null;
    }
  }

  String get displayAr {
    switch (this) {
      case PaymentStatus.PAID:
        return 'مدفوع';
      case PaymentStatus.NOT_REQUIRED:
        return 'مشمول بالاشتراك';
    }
  }

  String get displayEn {
    switch (this) {
      case PaymentStatus.PAID:
        return 'Paid';
      case PaymentStatus.NOT_REQUIRED:
        return 'Covered by subscription';
    }
  }
}
