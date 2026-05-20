import '../../../../generated/locale_keys.g.dart';

enum BikerNote {
  specialNote(key: LocaleKeys.bookings_special_note, ar: '', en: ''),
  dontCall(
    key: LocaleKeys.bookings_dont_call,
    ar: 'لا تتصل بالهاتف',
    en: "Don't call",
  ),
  outsideOnly(
    key: LocaleKeys.bookings_outside_only,
    ar: 'غسيل خارجي فقط',
    en: 'Outside only',
  );

  final String key;
  final String ar;
  final String en;

  const BikerNote({required this.key, required this.ar, required this.en});

  String getValue(bool isAr) => isAr ? ar : en;

  static BikerNote? fromKey(String key) {
    for (final note in BikerNote.values) {
      if (note.key == key) return note;
    }
    return null;
  }
}
