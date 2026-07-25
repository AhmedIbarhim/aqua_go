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
        'expiresAt': '2026-07-24T10:00:00Z',
        'promoCode': 'WELCOME15',
        'promoDiscountMinor': 2000,
      });
      expect(q.quoteId, 'q-1');
      expect(q.totalMinor, 11500);
      expect(q.vatMinor, 1500);
      expect(q.promoCode, 'WELCOME15');
      expect(q.promoDiscountMinor, 2000);
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
