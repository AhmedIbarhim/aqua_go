import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_go/features/booking/data/models/quote_model.dart';
import 'package:aqua_go/core/pricing/gross_price_breakdown.dart';

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

  group(
    'points-on-the-taxable-base — Total is the ONLY payable figure',
    () {
      // Pins the exact scenario reported: subtotal 175.00, promo 50.00 off,
      // points worth 24.00 redeemed. Points are now a discount on the taxable
      // base, exactly like the promo, so the backend re-extracts VAT AFTER
      // both discounts and totalMinor lands at 101.00 — not 125.00 (subtotal
      // − promo only) and not 77.00 (the old total-minus-points tender math).
      const subtotalMinor = 17500;
      const promoDiscountMinor = 5000;
      const pointsDiscountMinor = 2400;
      const totalMinor = 10100; // 175.00 - 50.00 - 24.00 = 101.00
      const vatMinor = 1317; // 15% of the post-discount gross, backend-stated

      final pointsQuote = QuoteModel.fromJson({
        'quoteId': 'q-points-1',
        'currency': 'SAR',
        'expiresAt': '2026-07-24T10:00:00Z',
        'promo': {
          'code': 'NEWCUST50',
          'discountType': 'FIXED_AMOUNT',
          'fixedAmountMinor': promoDiscountMinor,
          'discountMinor': promoDiscountMinor,
        },
        'breakdown': {
          'grossMinor': totalMinor,
          'totalMinor': totalMinor,
          'vatMinor': vatMinor,
          'promoDiscountMinor': promoDiscountMinor,
          'pointsDiscountMinor': pointsDiscountMinor,
          // Wire back-compat only — equals totalMinor exactly now that points
          // reduce the taxable base; the client never renders this field.
          'amountDueMinor': totalMinor,
          'currency': 'SAR',
        },
        'loyalty': {
          'currentBalancePoints': pointsDiscountMinor,
          'currentBalanceValueMinor': pointsDiscountMinor,
          'maxApplicablePoints': pointsDiscountMinor,
          'discountMinorAtMax': pointsDiscountMinor,
          'pointsApplied': pointsDiscountMinor,
          'pointsDiscountMinor': pointsDiscountMinor,
        },
      });

      test('QuoteModel surfaces totalMinor as the already points-net figure', () {
        expect(pointsQuote.totalMinor, totalMinor);
        expect(pointsQuote.pointsDiscountMinor, pointsDiscountMinor);
        // The wire still carries amountDueMinor for back-compat, and it is
        // now defined to equal totalMinor exactly — the client renders
        // neither field as a second payable row.
        expect(pointsQuote.amountDueMinor, pointsQuote.totalMinor);
      });

      test(
        'GrossPriceBreakdown.fromBookingLines reconciles subtotal − promo − '
        'points == total, and there is no separate amountDue figure',
        () {
          final breakdown = GrossPriceBreakdown.fromBookingLines(
            itemLines: const [
              GrossLine(label: 'Wash', grossMinor: subtotalMinor),
            ],
            discountMinor: promoDiscountMinor,
            promoCode: pointsQuote.promoCode,
            totalMinor: pointsQuote.totalMinor,
            vatMinor: pointsQuote.vatMinor,
            pointsDiscountMinor: pointsQuote.pointsDiscountMinor ?? 0,
          );

          expect(breakdown.hasDiscount, isTrue);
          expect(breakdown.hasPointsDiscount, isTrue);
          expect(breakdown.subtotalMinor, subtotalMinor);
          expect(breakdown.discountMinor, promoDiscountMinor);
          expect(breakdown.pointsDiscountMinor, pointsDiscountMinor);
          expect(breakdown.totalMinor, totalMinor);
          expect(breakdown.total, closeTo(101.00, 0.001));
          // The one arithmetic statement this layout makes, now that both
          // discounts land on the same taxable-base ladder.
          expect(breakdown.totalReconciles, isTrue);
          expect(
            breakdown.subtotalMinor -
                breakdown.discountMinor -
                breakdown.pointsDiscountMinor,
            breakdown.totalMinor,
          );
        },
      );

      test(
        'a booking-detail breakdown with no points reconciles on subtotal − '
        'promo alone',
        () {
          final breakdown = GrossPriceBreakdown.fromBookingLines(
            itemLines: const [GrossLine(label: 'Wash', grossMinor: 20500)],
            discountMinor: 0,
            promoCode: null,
            totalMinor: 20500,
            vatMinor: 2673,
          );

          expect(breakdown.hasPointsDiscount, isFalse);
          expect(breakdown.totalReconciles, isTrue);
        },
      );
    },
  );
}
