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
      'totalMinor': 9500,
      'vatMinor': 1239,
      'currency': 'SAR',
      'expiresAt': '2026-07-24T10:00:00Z',
      'promoCode': 'WELCOME15',
      'promoDiscountMinor': 2000,
      'breakdown': {
        'grossMinor': 9500,
        'netMinor': 8261,
        'vatMinor': 1239,
        'currency': 'SAR',
      },
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
