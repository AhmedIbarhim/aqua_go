import 'package:flutter_test/flutter_test.dart';

import 'package:aqua_go/features/booking/data/models/payment_init_model.dart';
import 'package:aqua_go/features/booking/presentation/widgets/booking_summary_widgets/booking_payable_total.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/breakdown.dart';

/// AQG-424 / AQG-425 — the booking summary's "does this need payment?"
/// decision must read the POST-discount total.
///
/// `Breakdown.gross` falls back through `grossMinor` FIRST, so on a quote
/// that carries both figures it is the PRE-discount subtotal. A 100% promo
/// leaves `grossMinor: 6000, totalMinor: 0` — `gross` reads 60.00 and
/// `total` reads 0.00. The action sheet was reading `gross`.
void main() {
  group('Breakdown payable figure', () {
    test('a fully discounted quote has a zero total and a non-zero gross', () {
      final b = Breakdown(
        grossMinor: 6000,
        totalMinor: 0,
        vatMinor: 0,
        netMinor: 0,
        promoDiscountMinor: 6000,
        currency: 'SAR',
      );

      expect(b.gross, 60.0, reason: 'gross is the PRE-discount subtotal');
      expect(b.total, 0.0, reason: 'total is what the customer actually pays');
    });

    test('a quote with no discount reports the same figure both ways', () {
      final b = Breakdown(
        grossMinor: 6000,
        totalMinor: 6000,
        vatMinor: 900,
        netMinor: 5100,
        currency: 'SAR',
      );

      expect(b.gross, 60.0);
      expect(b.total, 60.0);
    });

    test('a legacy quote with only grossMinor still reports a total', () {
      // The fallback that makes `total` safe to switch to: an older payload
      // with no `totalMinor` must not suddenly read 0 and skip payment.
      final b = Breakdown(grossMinor: 6000, currency: 'SAR');

      expect(
        b.total,
        60.0,
        reason: 'total falls back to grossMinor — never to 0',
      );
    });
  });

  group('payableTotalMajor', () {
    test('a fully discounted quote is payable-zero', () {
      expect(
        payableTotalMajor(
          Breakdown(grossMinor: 6000, totalMinor: 0, currency: 'SAR'),
        ),
        0.0,
      );
    });

    test(
      'a partially discounted quote is payable at the discounted figure',
      () {
        expect(
          payableTotalMajor(
            Breakdown(grossMinor: 6000, totalMinor: 4500, currency: 'SAR'),
          ),
          45.0,
        );
      },
    );

    test('points reduce the payable figure below the total', () {
      // amountDueMinor is the post-points figure the server computes.
      expect(
        payableTotalMajor(
          Breakdown(
            grossMinor: 6000,
            totalMinor: 6000,
            pointsDiscountMinor: 6000,
            amountDueMinor: 0,
            currency: 'SAR',
          ),
        ),
        0.0,
      );
    });

    test('a legacy quote with only grossMinor is payable at the gross', () {
      // The same never-read-zero fallback `Breakdown.total` carries: an older
      // payload must not silently become a free booking.
      expect(
        payableTotalMajor(Breakdown(grossMinor: 6000, currency: 'SAR')),
        60.0,
      );
    });

    test('a null breakdown is payable-zero', () {
      expect(payableTotalMajor(null), 0.0);
    });
  });

  group('needsPaymentMethod (affordance)', () {
    test('a zero payable total needs no payment method', () {
      expect(
        needsPaymentMethod(payableTotal: 0.0, hasPayableAddon: false),
        isFalse,
      );
    });

    test('a positive payable total needs a payment method', () {
      expect(
        needsPaymentMethod(payableTotal: 45.0, hasPayableAddon: false),
        isTrue,
      );
    });

    test('a zero total with a payable add-on still needs a payment method', () {
      // The package flow charges add-ons separately from the wash.
      expect(
        needsPaymentMethod(payableTotal: 0.0, hasPayableAddon: true),
        isTrue,
      );
    });
  });

  group('shouldOpenPaymentSdk (authoritative)', () {
    PaymentInitModel init(int amountMinor) => PaymentInitModel(
      amountMinor: amountMinor,
      givenId: 'g',
      currency: 'SAR',
      metadata: const {},
      holdToken: 'h',
    );

    test('a server amount of zero never opens the SDK', () {
      expect(shouldOpenPaymentSdk(init(0)), isFalse);
    });

    test('a positive server amount opens the SDK', () {
      expect(shouldOpenPaymentSdk(init(4500)), isTrue);
    });

    test('the SDK decision ignores client-side totals entirely', () {
      // R1 — the client must never decide whether a card is charged. The
      // server re-prices at payment-init; if it says zero, it is zero, and
      // if it says 45.00 after the client thought zero, the card is charged.
      expect(shouldOpenPaymentSdk(init(4500)), isTrue);
    });
  });
}
