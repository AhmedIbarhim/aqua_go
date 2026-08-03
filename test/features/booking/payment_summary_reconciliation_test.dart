import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_go/features/booking/data/models/quote_model.dart';

/// Locks the invariant PaymentSummaryCard depends on: the backend quote
/// breakdown is ALREADY net of any applied promo, so Subtotal + VAT == Total
/// with `promoDiscountMinor` playing NO part in the arithmetic. The second
/// test spells out exactly how far off the column would be if someone
/// reintroduced a `-promoDiscount` row between Subtotal and VAT.
void main() {
  group('promo-applied quote breakdown', () {
    // Base gross 11500 minor, promo 2000 minor, 15% VAT-inclusive:
    // discountedGross 9500 -> vat 1239, net 8261.
    final promoQuote = QuoteModel.fromJson({
      'quoteId': 'q-promo-1',
      'currency': 'SAR',
      'expiresAt': '2026-07-24T10:00:00Z',
      'promo': {
        'code': 'WELCOME15',
        'discountType': 'FIXED_AMOUNT',
        'fixedAmountMinor': 2000,
        'discountMinor': 2000,
      },
      'breakdown': {
        'grossMinor': 9500,
        'netMinor': 8261,
        'vatMinor': 1239,
        'totalMinor': 9500,
        'promoDiscountMinor': 2000,
        'currency': 'SAR',
      },
    });

    test('the promo is reported but never re-applied by the model', () {
      // Both surface the applied promo for display; neither feeds the totals.
      expect(promoQuote.promoCode, 'WELCOME15');
      expect(promoQuote.promoDiscountMinor, 2000);
      // totalMinor is the POST-discount total, straight from the breakdown.
      expect(promoQuote.totalMinor, 9500);
      expect(promoQuote.vatMinor, 1239);
    });

    test('subtotal + vat reconciles to total with no discount row', () {
      final b = promoQuote.breakdown!;
      expect(b.netMinor! + b.vatMinor!, b.grossMinor);
      expect(b.net + b.vat, closeTo(b.gross, 0.001));
    });

    test('subtracting the promo a second time breaks the column', () {
      final b = promoQuote.breakdown!;
      final doubleSubtracted =
          b.netMinor! - promoQuote.promoDiscountMinor + b.vatMinor!;
      expect(doubleSubtracted, isNot(b.grossMinor));
      expect(doubleSubtracted, 7500);
    });
  });
}
