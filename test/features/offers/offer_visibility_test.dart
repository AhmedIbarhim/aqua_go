import 'package:aqua_go/features/offers/data/models/customer_offer_model.dart';
import 'package:aqua_go/features/offers/domain/offer_visibility.dart';
import 'package:flutter_test/flutter_test.dart';

/// `endsAt` and `now` both live in the Riyadh frame — UTC-flagged, carrying
/// Asia/Riyadh wall-clock fields — so `DateTime.utc(...)` is the correct way to
/// build a fixture here and `DateTime.now()` is never one.
CustomerOfferModel _offer(String id, DateTime endsAt) => CustomerOfferModel(
      id: id,
      offerType: 'PROMO_CODE',
      titleAr: 'ع',
      titleEn: 'T',
      descriptionAr: 'و',
      descriptionEn: 'D',
      endsAt: endsAt,
      terms: const OfferTermsModel(promoCode: 'X'),
    );

void main() {
  final now = DateTime.utc(2026, 7, 27, 12);

  test('an offer whose window has already closed is DROPPED, not just sorted last', () {
    // UCC23 step 2 — the list holds offers "whose start/end window includes the
    // current date and time". A feed that went stale in the customer's hand
    // must not keep rendering a dead card at the bottom.
    final visible = visibleOffers(
      [_offer('gone', now.subtract(const Duration(minutes: 1))), _offer('live', now.add(const Duration(days: 3)))],
      now,
    );
    expect(visible.map((o) => o.id), ['live']);
  });

  test('endsAt is EXCLUSIVE — an offer ending exactly now is already over', () {
    // Mirrors CustomerOfferView.endsAt: "when the offer stops being shown
    // (exclusive)". Equal instants are out, not in.
    expect(visibleOffers([_offer('boundary', now)], now), isEmpty);
  });

  test('an offer ending one minute from now is still visible', () {
    final visible = visibleOffers([_offer('nearly', now.add(const Duration(minutes: 1)))], now);
    expect(visible.map((o) => o.id), ['nearly']);
  });

  test('survivors are ordered endsAt ASC, so what closes soonest is first', () {
    final visible = visibleOffers(
      [
        _offer('late', now.add(const Duration(days: 30))),
        _offer('soon', now.add(const Duration(days: 2))),
        _offer('mid', now.add(const Duration(days: 9))),
      ],
      now,
    );
    expect(visible.map((o) => o.id), ['soon', 'mid', 'late']);
  });

  test('an offer expiring at Riyadh midnight dies at Riyadh midnight, on any '
      'device', () {
    // The regression this suite previously could not see. The server sends
    // `endsAt: "2026-08-01T00:00:00"` — bare Riyadh midnight — and the old
    // pipeline parsed it device-locally, so the card outlived its window by the
    // device's offset (3 hours on a UTC phone) or died early (6 hours in Tokyo).
    // Building the fixture from the WIRE STRING is what makes this a real test
    // of the parse rather than of the comparison alone.
    final offer = CustomerOfferModel.fromJson({
      'id': 'midnight',
      'offerType': 'PROMO_CODE',
      'titleAr': 'ع',
      'titleEn': 'T',
      'descriptionAr': 'و',
      'descriptionEn': 'D',
      'endsAt': '2026-08-01T00:00:00',
      'terms': {'promoCode': 'X'},
    });
    final midnight = DateTime.utc(2026, 8, 1);

    expect(
      visibleOffers([offer], midnight.subtract(const Duration(minutes: 1))),
      hasLength(1),
      reason: 'a minute before Riyadh midnight the offer is still live',
    );
    expect(
      visibleOffers([offer], midnight),
      isEmpty,
      reason: 'at Riyadh midnight it is over — endsAt is EXCLUSIVE',
    );
    // The three hours the old parse handed a UTC device for free.
    expect(
      visibleOffers([offer], midnight.add(const Duration(hours: 2, minutes: 59))),
      isEmpty,
      reason: 'it must not survive into the device-offset window',
    );
  });

  test('the input list is not mutated', () {
    final input = [
      _offer('late', now.add(const Duration(days: 30))),
      _offer('soon', now.add(const Duration(days: 2))),
    ];
    visibleOffers(input, now);
    expect(input.map((o) => o.id), ['late', 'soon']);
  });

  test('an empty feed stays empty', () {
    expect(visibleOffers(const [], now), isEmpty);
  });
}
