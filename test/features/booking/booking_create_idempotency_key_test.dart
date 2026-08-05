import 'package:flutter_test/flutter_test.dart';

import 'package:aqua_go/features/booking/data/models/quote_model.dart';
import 'package:aqua_go/features/booking/data/models/service_booking_request_model.dart';
import 'package:aqua_go/features/booking/data/repos/booking_repository.dart';

/// Risk R2 — `booking-create:${booking.moyasarPaymentId}` interpolates a null
/// `moyasarPaymentId` to the LITERAL string `booking-create:null`, which is
/// one constant key shared by every zero-total booking from every customer.
///
/// `booking.idempotency_keys.key` is a bare PRIMARY KEY (booking/V2:60) and
/// `IdempotencyKeyFilter` resolves it without consulting the principal, so for
/// the 7-day retention window the SECOND free booking on the platform either
/// 422s (different body — the common case) or replays the FIRST customer's
/// cached 201 (identical body — the leak). Neither is acceptable. The
/// server-side proof of the consequence is `BookingCreateIdempotencyScopeIT`.
QuoteModel _quote(String id) => QuoteModel(
  quoteId: id,
  currency: 'SAR',
  expiresAt: DateTime.now().add(const Duration(minutes: 15)),
);

void main() {
  group('bookingCreateIdempotencyKey', () {
    test('a paid booking keys off the verified payment id', () {
      final k = bookingCreateIdempotencyKey(
        ServiceBookingRequestModel(
          quote: _quote('q-1'),
          moyasarPaymentId: 'pay_abc123',
        ),
      );

      expect(k, 'booking-create:pay_abc123');
    });

    test('a card-less booking never contains the literal "null"', () {
      final k = bookingCreateIdempotencyKey(
        ServiceBookingRequestModel(quote: _quote('q-1'), moyasarPaymentId: null),
      );

      expect(k, isNot(contains('null')));
    });

    test('two card-less bookings on different quotes get different keys', () {
      final a = bookingCreateIdempotencyKey(
        ServiceBookingRequestModel(
          quote: _quote('q-aaa'),
          moyasarPaymentId: null,
        ),
      );
      final b = bookingCreateIdempotencyKey(
        ServiceBookingRequestModel(
          quote: _quote('q-bbb'),
          moyasarPaymentId: null,
        ),
      );

      expect(a, isNot(equals(b)));
    });

    test('a card-less booking keys off its own quote', () {
      final k = bookingCreateIdempotencyKey(
        ServiceBookingRequestModel(
          quote: _quote('q-aaa'),
          moyasarPaymentId: null,
        ),
      );

      expect(k, 'booking-create:quote:q-aaa');
    });

    test('a retry of the SAME card-less booking replays the SAME key', () {
      // The property that must SURVIVE: a network retry of one create is
      // still idempotent. A quote belongs to exactly one customer (the server
      // re-checks quote.customerId at create), so a quote-scoped key is both
      // unique across customers and stable across retries.
      final model = ServiceBookingRequestModel(
        quote: _quote('q-aaa'),
        moyasarPaymentId: null,
      );

      expect(
        bookingCreateIdempotencyKey(model),
        bookingCreateIdempotencyKey(model),
      );
    });

    test('an empty payment id falls through to the quote rather than keying on ""', () {
      final k = bookingCreateIdempotencyKey(
        ServiceBookingRequestModel(quote: _quote('q-aaa'), moyasarPaymentId: ''),
      );

      expect(k, 'booking-create:quote:q-aaa');
    });

    test('a booking with neither a payment nor a quote is rejected loudly', () {
      expect(
        () => bookingCreateIdempotencyKey(
          ServiceBookingRequestModel(quote: null, moyasarPaymentId: null),
        ),
        throwsStateError,
      );
    });
  });
}
