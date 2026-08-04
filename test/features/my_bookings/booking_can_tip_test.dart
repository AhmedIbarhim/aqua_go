import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// UC-C19 — the tip window closes some days after the wash completes and its
/// length is an admin dial, so the app must not decide for itself whether a tip
/// is still possible. `canTip` is the server's answer; these tests pin the
/// parsing, and above all the ABSENT case, because that is what an app talking
/// to an older server sees and the wrong default there offers a tip that fails
/// only after the customer has picked an amount.
Map<String, dynamic> _bookingJson({Object? canTip = _absent}) => {
  'id': 'booking-1',
  'referenceNumber': 'BK-000123',
  'type': 'SCHEDULED',
  'status': 'COMPLETED',
  'totalAmountMinor': 9500,
  'currency': 'SAR',
  'tipPaid': false,
  if (!identical(canTip, _absent)) 'canTip': canTip,
};

const Object _absent = Object();

void main() {
  test('canTip is false when the server omits the field', () {
    // An older backend sends no canTip at all. Hiding the action is the only
    // safe reading — the alternative offers a tip the tip endpoint rejects.
    expect(BookingResponseModel.fromJson(_bookingJson()).canTip, isFalse);
  });

  test('canTip is false when the server sends null', () {
    expect(
      BookingResponseModel.fromJson(_bookingJson(canTip: null)).canTip,
      isFalse,
    );
  });

  test('canTip mirrors the server boolean', () {
    expect(
      BookingResponseModel.fromJson(_bookingJson(canTip: true)).canTip,
      isTrue,
    );
    expect(
      BookingResponseModel.fromJson(_bookingJson(canTip: false)).canTip,
      isFalse,
    );
  });

  test('canTip does not fall back to tipPaid', () {
    // The bug this closes: gating on `tipPaid == false` alone treated every
    // untipped COMPLETED booking as tippable, including ones finished months
    // ago. An untipped booking with the window shut must read as NOT tippable.
    final closed = BookingResponseModel.fromJson(
      _bookingJson(canTip: false),
    );
    expect(closed.tipPaid, isFalse);
    expect(closed.canTip, isFalse);
  });

  test('a locally-built model defaults to not tippable', () {
    // BookingSummaryModel.toDetailsPlaceholder builds one of these from list
    // data that carries no canTip; the placeholder must not offer a tip before
    // the real detail lands.
    expect(BookingResponseModel(id: 'booking-1').canTip, isFalse);
  });
}
