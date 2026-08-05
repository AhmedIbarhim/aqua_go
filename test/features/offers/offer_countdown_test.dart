import 'package:aqua_go/features/offers/data/models/customer_offer_model.dart';
import 'package:aqua_go/features/offers/domain/offer_countdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 1, 1, 12);

  group('offerCountdown — the days tier', () {
    test('three full days remaining -> 3 days', () {
      final c = offerCountdown(now.add(const Duration(days: 3)), now)!;
      expect(c.unit, OfferCountdownUnit.days);
      expect(c.value, 3);
    });

    test('exactly seven days remaining -> no chip', () {
      expect(offerCountdown(now.add(const Duration(days: 7)), now), isNull);
    });

    test('more than seven days remaining -> no chip', () {
      expect(offerCountdown(now.add(const Duration(days: 30)), now), isNull);
    });

    test('six days and 23 hours -> rounds UP to 7 days', () {
      // The days tier keeps its documented round-UP: a part-day reads as a
      // whole day. Unchanged by this fix, and locked here on purpose.
      final c = offerCountdown(now.add(const Duration(days: 6, hours: 23)), now)!;
      expect(c.unit, OfferCountdownUnit.days);
      expect(c.value, 7);
    });

    test('exactly 24 hours remaining -> 1 day, not 24 hours', () {
      final c = offerCountdown(now.add(const Duration(days: 1)), now)!;
      expect(c.unit, OfferCountdownUnit.days);
      expect(c.value, 1);
    });
  });

  group('offerCountdown — the hours tier', () {
    test('23h59m remaining -> 23 hours, never 24', () {
      // Sub-day units round DOWN. Rounding up here would print
      // "Ends in 24 hours" for something 23h59 away — an OVERSTATEMENT of
      // the time left, which is the one direction a countdown must not err.
      final c = offerCountdown(
          now.add(const Duration(hours: 23, minutes: 59)), now)!;
      expect(c.unit, OfferCountdownUnit.hours);
      expect(c.value, 23);
    });

    test('exactly one hour remaining -> 1 hour', () {
      final c = offerCountdown(now.add(const Duration(hours: 1)), now)!;
      expect(c.unit, OfferCountdownUnit.hours);
      expect(c.value, 1);
    });

    test('1h59m remaining -> 1 hour', () {
      final c = offerCountdown(
          now.add(const Duration(hours: 1, minutes: 59)), now)!;
      expect(c.unit, OfferCountdownUnit.hours);
      expect(c.value, 1);
    });
  });

  group('offerCountdown — the minutes tier', () {
    test('the AQG-437 case: five minutes remaining -> 5 minutes', () {
      final c = offerCountdown(now.add(const Duration(minutes: 5)), now)!;
      expect(c.unit, OfferCountdownUnit.minutes);
      expect(c.value, 5);
    });

    test('thirty minutes remaining -> 30 minutes, not "1 day"', () {
      final c = offerCountdown(now.add(const Duration(minutes: 30)), now)!;
      expect(c.unit, OfferCountdownUnit.minutes);
      expect(c.value, 30);
    });

    test('59m59s remaining -> 59 minutes', () {
      final c = offerCountdown(
          now.add(const Duration(minutes: 59, seconds: 59)), now)!;
      expect(c.unit, OfferCountdownUnit.minutes);
      expect(c.value, 59);
    });

    test('under a minute remaining -> floors at 1 minute, never 0', () {
      final c = offerCountdown(now.add(const Duration(seconds: 30)), now)!;
      expect(c.unit, OfferCountdownUnit.minutes);
      expect(c.value, 1);
    });
  });

  group('offerCountdown — boundaries and frames', () {
    test('already ended -> no chip', () {
      expect(offerCountdown(now.subtract(const Duration(hours: 1)), now), isNull);
    });

    test('ending exactly now -> no chip', () {
      expect(offerCountdown(now, now), isNull);
    });

    test('the chip does not move with the device timezone', () {
      // Both arguments live in the Riyadh frame — UTC-flagged, carrying
      // Riyadh wall-clock fields — so the boundary falls at the same wall
      // clock on every device. Built from the WIRE STRING, so the parse is
      // under test too.
      final offer = CustomerOfferModel.fromJson({
        'id': 'x',
        'offerType': 'PROMO_CODE',
        'titleAr': 'ع',
        'titleEn': 'T',
        'descriptionAr': 'و',
        'descriptionEn': 'D',
        'endsAt': '2026-08-03T00:00:00',
        'terms': {'promoCode': 'X'},
      });
      final c = offerCountdown(offer.endsAt, DateTime.utc(2026, 8, 1))!;
      expect(c.unit, OfferCountdownUnit.days);
      expect(c.value, 2);
      expect(offerCountdown(offer.endsAt, DateTime.utc(2026, 7, 27)), isNull);
    });

    test('the CustomerOfferModel far-future fallback renders no chip', () {
      expect(offerCountdown(DateTime.utc(9999, 12, 31), now), isNull);
    });
  });
}
