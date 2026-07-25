import 'package:aqua_go/features/offers/domain/offer_countdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 1, 1, 12);

  group('offerEndsInDays', () {
    test('three full days remaining -> 3', () {
      expect(offerEndsInDays(now.add(const Duration(days: 3)), now), 3);
    });

    test('exactly seven days remaining -> no chip', () {
      expect(offerEndsInDays(now.add(const Duration(days: 7)), now), isNull);
    });

    test('more than seven days remaining -> no chip', () {
      expect(offerEndsInDays(now.add(const Duration(days: 30)), now), isNull);
    });

    test('six days and 23 hours -> rounds up to 7', () {
      expect(offerEndsInDays(now.add(const Duration(days: 6, hours: 23)), now), 7);
    });

    test('thirty minutes remaining -> floors at 1', () {
      expect(offerEndsInDays(now.add(const Duration(minutes: 30)), now), 1);
    });

    test('already ended -> no chip', () {
      expect(offerEndsInDays(now.subtract(const Duration(hours: 1)), now), isNull);
    });

    test('local-time endsAt is compared in UTC', () {
      final local = now.add(const Duration(days: 2)).toLocal();
      expect(offerEndsInDays(local, now), 2);
    });

    test('the CustomerOfferModel far-future fallback renders no chip', () {
      expect(offerEndsInDays(DateTime.utc(9999, 12, 31), now), isNull);
    });
  });
}
