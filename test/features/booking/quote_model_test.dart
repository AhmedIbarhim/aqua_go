import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_go/features/booking/data/models/quote_model.dart';

/// Read-reconstruction cover for [QuoteModel.fromJson]. Every field degrades to
/// a safe default so a partial/legacy payload yields a usable model instead of
/// a TypeError that kills the booking screen. The money-bearing sub-objects go
/// through `num` so a JSON double (1500.0) parses as cleanly as an int.
///
/// NOTE: on this branch the money getters (`totalMinor`, `vatMinor`,
/// `promoDiscountMinor`, `promoCode`) are DERIVED from `breakdown` / `promo`,
/// not read off the top level of the payload — the cases below feed the nested
/// shape the backend actually sends.
void main() {
  group('QuoteModel.fromJson', () {
    test('parses a fully populated payload', () {
      final q = QuoteModel.fromJson({
        'quoteId': 'q-1',
        'currency': 'SAR',
        'expiresAt': '2026-07-24T10:00:00Z',
        'promo': {
          'code': 'WELCOME15',
          'discountType': 'FIXED_AMOUNT',
          'fixedAmountMinor': 2000,
          'discountMinor': 2000,
        },
        'breakdown': {
          'grossMinor': 11500,
          'netMinor': 10000,
          'vatMinor': 1500,
          'totalMinor': 11500,
          'promoDiscountMinor': 2000,
          'currency': 'SAR',
        },
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
      expect(q.breakdown, isNull);
      expect(q.surge, isNull);
      expect(q.promo, isNull);
      expect(q.loyalty, isNull);
    });

    test('totalMinor falls back to grossMinor when totalMinor is absent', () {
      // Legacy breakdowns carried gross only; the getter must not read 0.
      final q = QuoteModel.fromJson({
        'quoteId': 'q-legacy',
        'breakdown': {'grossMinor': 11500, 'netMinor': 10000, 'vatMinor': 1500},
      });
      expect(q.totalMinor, 11500);
      expect(q.vatMinor, 1500);
    });

    test('accepts money fields delivered as JSON doubles', () {
      final q = QuoteModel.fromJson({
        'quoteId': 'q-2',
        'surge': {'timeBps': 1000.0, 'zoneBps': 0, 'demandBps': 500.0},
        'promo': {'code': 'WELCOME15', 'discountMinor': 2000.0},
        'loyalty': {
          'currentBalancePoints': 300.0,
          'currentBalanceValueMinor': 3000.0,
          'maxApplicablePoints': 200.0,
          'discountMinorAtMax': 2000.0,
          'pointsApplied': 150.0,
          'pointsDiscountMinor': 1500.0,
        },
      });
      expect(q.surge!.timeBps, 1000);
      expect(q.surge!.demandBps, 500);
      expect(q.promo!.discountMinor, 2000);
      expect(q.currentBalancePoints, 300);
      expect(q.maxApplicablePoints, 200);
      expect(q.pointsApplied, 150);
      expect(q.pointsDiscountMinor, 1500);
    });

    test('degrades a partial promo/loyalty object instead of throwing', () {
      final q = QuoteModel.fromJson({
        'quoteId': 'q-4',
        'promo': <String, dynamic>{},
        'loyalty': <String, dynamic>{},
      });
      expect(q.promo!.code, '');
      expect(q.promo!.discountType, '');
      expect(q.promo!.percent, 0);
      expect(q.maxApplicablePoints, 0);
      expect(q.pointsDiscountMinor, 0);
    });

    test('falls back to now() on a malformed expiresAt instead of throwing', () {
      // Everything before expiresAt is present so the date parse is what fails.
      final q = QuoteModel.fromJson({
        'quoteId': 'q-3',
        'currency': 'SAR',
        'expiresAt': 'not-a-date',
      });
      expect(q.expiresAt.isUtc, isTrue);
    });
  });
}
