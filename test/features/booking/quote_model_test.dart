import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_go/features/booking/data/models/quote_model.dart';

void main() {
  group('QuoteModel.fromJson', () {
    test('parses a fully populated payload', () {
      final q = QuoteModel.fromJson({
        'quoteId': 'q-1',
        'totalMinor': 11500,
        'vatMinor': 1500,
        'currency': 'SAR',
        // Bare Riyadh wall clock — no offset, no `Z`. That is the only shape
        // the backend emits, and a `Z` here would hide the device-local parse.
        'expiresAt': '2026-07-24T13:00:00',
        'promoCode': 'WELCOME15',
        'promoDiscountMinor': 2000,
        'timeMultiplierBps': 12000,
        'zoneMultiplierBps': 11000,
        'demandMultiplierBps': 10500,
        'surgedSubtotalMinor': 10000,
      });
      expect(q.quoteId, 'q-1');
      expect(q.totalMinor, 11500);
      expect(q.vatMinor, 1500);
      expect(q.promoCode, 'WELCOME15');
      expect(q.promoDiscountMinor, 2000);
      expect(q.timeMultiplierBps, 12000);
      expect(q.zoneMultiplierBps, 11000);
      expect(q.demandMultiplierBps, 10500);
      expect(q.surgedSubtotalMinor, 10000);
      expect(q.isSurged, isTrue);
    });

    test('expiresAt lands in the Riyadh frame, on any device', () {
      // The wire value is a bare wall clock. `DateTime.tryParse` alone returns a
      // DEVICE-LOCAL instant, so the price-lock check in booking_summary_view
      // fired ~3h late on a UTC device and ~2h early on UTC+5. Equality here
      // pins the UTC flag as well as the instant, so it fails on every device
      // under the old parse — including a UTC+3 one.
      final q = QuoteModel.fromJson({
        'quoteId': 'q-tz',
        'expiresAt': '2026-07-24T13:00:00',
        'promoDiscountMinor': 0,
      });
      expect(q.expiresAt, DateTime.utc(2026, 7, 24, 13));
    });

    test('an absent multiplier reads as UNSCALED, never as zero', () {
      // 0 bps would describe a free wash on this read-reconstruction path.
      final q = QuoteModel.fromJson({'quoteId': 'q-4'});
      expect(q.timeMultiplierBps, kMultiplierBpsUnit);
      expect(q.zoneMultiplierBps, kMultiplierBpsUnit);
      expect(q.demandMultiplierBps, kMultiplierBpsUnit);
      expect(q.surgedSubtotalMinor, 0);
      expect(q.isSurged, isFalse);
    });

    test('toJson re-emits expiresAt as a BARE wall clock', () {
      // `toIso8601String()` would stamp a `Z` on the UTC-flagged Riyadh frame
      // and mis-date the value by three hours on the way back out.
      final q = QuoteModel.fromJson({
        'quoteId': 'q-5',
        'expiresAt': '2026-07-24T13:00:00',
        'promoDiscountMinor': 0,
      });
      expect(q.toJson()['expiresAt'], '2026-07-24T13:00:00');
      expect(QuoteModel.fromJson(q.toJson()).expiresAt, q.expiresAt);
    });

    test('survives an empty payload instead of throwing', () {
      final q = QuoteModel.fromJson(<String, dynamic>{});
      expect(q.quoteId, '');
      expect(q.totalMinor, 0);
      expect(q.vatMinor, 0);
      expect(q.currency, 'SAR');
      expect(q.promoCode, isNull);
      expect(q.promoDiscountMinor, 0);
      expect(q.lines, isEmpty);
    });

    test('accepts money fields delivered as JSON doubles', () {
      // quoteId is present so the FIRST cast to fail is the totalMinor double.
      final q = QuoteModel.fromJson({
        'quoteId': 'q-2',
        'totalMinor': 11500.0,
        'vatMinor': 1500.0,
        'promoDiscountMinor': 2000.0,
      });
      expect(q.totalMinor, 11500);
      expect(q.vatMinor, 1500);
      expect(q.promoDiscountMinor, 2000);
    });

    test('falls back to now() on a malformed expiresAt instead of throwing', () {
      // Everything before expiresAt is present so the date parse is what fails.
      final q = QuoteModel.fromJson({
        'quoteId': 'q-3',
        'totalMinor': 0,
        'vatMinor': 0,
        'currency': 'SAR',
        'expiresAt': 'not-a-date',
        'promoDiscountMinor': 0,
      });
      expect(q.expiresAt.isUtc, isTrue);
    });
  });
}
