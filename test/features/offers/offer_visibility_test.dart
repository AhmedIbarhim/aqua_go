import 'package:aqua_go/features/offers/data/models/customer_offer_model.dart';
import 'package:aqua_go/features/offers/domain/offer_visibility.dart';
import 'package:flutter_test/flutter_test.dart';

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

  test('local and UTC instants compare on the same axis', () {
    // endsAt arrives UTC from the API; `now` is DateTime.now(), which is local.
    // Comparing without normalising would drift by the +03:00 Riyadh offset and
    // keep a three-hour-dead offer on screen.
    final endsAt = now.add(const Duration(hours: 1));
    expect(visibleOffers([_offer('x', endsAt)], now.toLocal()), hasLength(1));
    expect(visibleOffers([_offer('x', endsAt.toLocal())], now), hasLength(1));
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
