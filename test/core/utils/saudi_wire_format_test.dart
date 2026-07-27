import 'package:aqua_go/core/utils/saudi_wire_format.dart';
import 'package:flutter_test/flutter_test.dart';

/// The backend emits every timestamp as a BARE Asia/Riyadh wall clock — no
/// offset, no `Z`. Every assertion below is written so that it holds on a device
/// in ANY timezone, which is the property the old `DateTime.tryParse(...)`
/// call sites silently lacked.
///
/// Run this file under a non-Riyadh zone to see that directly:
///   TZ=UTC        flutter test test/core/utils/saudi_wire_format_test.dart
///   TZ=Asia/Tokyo flutter test test/core/utils/saudi_wire_format_test.dart
void main() {
  group('tryParseWireDateTime', () {
    test('a bare wire value keeps its wall-clock fields, in the Riyadh frame', () {
      final parsed = tryParseWireDateTime('2026-08-01T00:00:00');
      // `DateTime` equality compares the instant AND the UTC flag, so this
      // pins the frame as well as the fields. A device-local parse fails it on
      // every device — including a UTC+3 one, where only the flag differs.
      expect(parsed, DateTime.utc(2026, 8, 1));
      expect(parsed!.isUtc, isTrue);
    });

    test('the parse does NOT move with the device timezone', () {
      // The bug this file exists for: `DateTime.parse` on an offset-less string
      // returns a device-local DateTime, so the instant it carries slides by the
      // device's own offset. Anchored to the machine clock, this assertion is
      // the device-independence claim itself rather than a restatement of it.
      final parsed = tryParseWireDateTime('2026-08-01T00:00:00')!;
      final deviceLocal = DateTime.parse('2026-08-01T00:00:00');
      final deviceOffset = DateTime.now().timeZoneOffset;
      expect(
        parsed.microsecondsSinceEpoch -
            deviceLocal.microsecondsSinceEpoch,
        deviceOffset.inMicroseconds,
        reason: 'the parsed instant must differ from a naive device-local parse '
            'by exactly the device offset — i.e. it does not contain one',
      );
    });

    test('sub-second precision survives', () {
      expect(
        tryParseWireDateTime('2026-08-01T13:45:30.123456'),
        DateTime.utc(2026, 8, 1, 13, 45, 30, 123, 456),
      );
    });

    test('an anchored value is converted to the Riyadh wall clock', () {
      // A `Z` or an explicit offset names a real instant, so its fields are NOT
      // read verbatim. `toIso8601String()` on a Riyadh-frame value produces
      // exactly this shape, so a local round-trip has to survive it.
      expect(
        tryParseWireDateTime('2026-08-01T00:00:00Z'),
        DateTime.utc(2026, 8, 1, 3),
      );
      expect(
        tryParseWireDateTime('2026-08-01T05:00:00+05:00'),
        DateTime.utc(2026, 8, 1, 3),
      );
    });

    test('a date-only value is not mistaken for an anchored one', () {
      // '2026-08-01' is full of hyphens; none of them is a UTC offset.
      expect(tryParseWireDateTime('2026-08-01'), DateTime.utc(2026, 8, 1));
    });

    test('an absent or unparseable value degrades to null, never throws', () {
      expect(tryParseWireDateTime(null), isNull);
      expect(tryParseWireDateTime(''), isNull);
      expect(tryParseWireDateTime('not-a-date'), isNull);
    });

    test('round-trips through toWireDateTime unchanged', () {
      const raw = '2026-08-01T13:45:30';
      expect(toWireDateTime(tryParseWireDateTime(raw)!), raw);
    });
  });

  group('saudiNow', () {
    test('shares the frame the parse produces', () {
      final now = saudiNow();
      expect(now.isUtc, isTrue);
      // Its fields are the Riyadh wall clock: UTC+3 ahead of the true UTC one.
      expect(
        now.difference(DateTime.now().toUtc()).inMinutes,
        closeTo(180, 1),
      );
    });
  });
}
