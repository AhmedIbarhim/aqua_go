import 'package:aqua_go/features/offers/data/models/customer_offer_model.dart';
import 'package:aqua_go/features/offers/domain/offer_term_lines.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:flutter_test/flutter_test.dart';

CustomerOfferModel _offer(String type, OfferTermsModel terms) => CustomerOfferModel(
      id: 'x',
      offerType: type,
      titleAr: 'ع',
      titleEn: 'T',
      descriptionAr: 'و',
      descriptionEn: 'D',
      endsAt: DateTime.utc(2026, 9, 1),
      terms: terms,
    );

// `offerExpiryLine` formats a date per locale, which needs the `intl` symbol
// data that GlobalMaterialLocalizations loads for the app — unavailable to a
// bare unit test. It is covered in offers_surface_test.dart instead, where the
// localisation delegates are real.
void main() {
  test('sarFromMinor renders two decimals', () {
    expect(sarFromMinor(24900), '249.00');
    expect(sarFromMinor(5000), '50.00');
    expect(sarFromMinor(0), '0.00');
  });

  test('a PERCENTAGE promo yields the percent line and the min-order line', () {
    final lines = offerTermLines(
      _offer(
        'PROMO_CODE',
        const OfferTermsModel(
          promoCode: 'WELCOME15',
          discountType: 'PERCENTAGE',
          configuredValue: 15,
          minOrderMinor: 5000,
        ),
      ),
      isAr: false,
    );
    expect(lines, hasLength(2));
    expect(lines[0].localeKey, LocaleKeys.offers_discount_percent);
    expect(lines[0].args, ['15']);
    expect(lines[1].localeKey, LocaleKeys.offers_min_order);
    expect(lines[1].args, ['50.00']);
  });

  test('a FIXED_AMOUNT promo renders the amount in SAR, not minor units', () {
    final lines = offerTermLines(
      _offer(
        'PROMO_CODE',
        const OfferTermsModel(
          promoCode: 'FLAT20',
          discountType: 'FIXED_AMOUNT',
          configuredValue: 2000,
        ),
      ),
      isAr: false,
    );
    expect(lines, hasLength(1));
    expect(lines[0].localeKey, LocaleKeys.offers_discount_amount);
    expect(lines[0].args, ['20.00']);
  });

  test('an unknown discount type yields no discount line (drift detector)', () {
    final lines = offerTermLines(
      _offer(
        'PROMO_CODE',
        const OfferTermsModel(promoCode: 'X', discountType: 'PERCENT', configuredValue: 15),
      ),
      isAr: false,
    );
    expect(lines, isEmpty,
        reason: 'PERCENT is NOT a backend literal — PromoServiceImpl emits '
            'PERCENTAGE / FIXED_AMOUNT. If this ever passes with a non-empty '
            'list the literals drifted.');
  });

  test('a PACKAGE offer yields name, washes, validity and price, localised', () {
    const terms = OfferTermsModel(
      packageId: 'pkg',
      packageNameAr: 'الباقة الذهبية',
      packageNameEn: 'Gold package',
      packagePriceMinor: 24900,
      packageNumWashes: 8,
      packageValidityDays: 30,
    );
    final en = offerTermLines(_offer('PACKAGE', terms), isAr: false);
    expect(en, hasLength(4));
    expect(en[0].literal, 'Gold package');
    expect(en[1].localeKey, LocaleKeys.offers_package_washes);
    expect(en[2].localeKey, LocaleKeys.offers_package_validity);
    expect(en[3].localeKey, LocaleKeys.offers_package_price);
    expect(en[3].args, ['249.00']);

    final ar = offerTermLines(_offer('PACKAGE', terms), isAr: true);
    expect(ar[0].literal, 'الباقة الذهبية');
  });

  group('offerMinOrderLine — BR-OFR-10 / AC-EXT-06 on the CARD', () {
    test('a promo offer carrying a minimum order states the threshold', () {
      // AC-EXT-06: "an offer carrying a minimum order value is shown, with the
      // threshold stated on the card and in the detail view."
      final line = offerMinOrderLine(_offer(
        'PROMO_CODE',
        const OfferTermsModel(promoCode: 'SAVE', discountType: 'PERCENTAGE', configuredValue: 20, minOrderMinor: 10000),
      ));
      expect(line, isNotNull);
      expect(line!.localeKey, LocaleKeys.offers_min_order);
      expect(line.args, ['100.00']);
    });

    test('an unrestricted promo offer states nothing', () {
      expect(
        offerMinOrderLine(_offer(
          'PROMO_CODE',
          const OfferTermsModel(promoCode: 'SAVE', discountType: 'PERCENTAGE', configuredValue: 20),
        )),
        isNull,
      );
    });

    test('a PACKAGE offer never carries a minimum order', () {
      // The package half of OfferTerms leaves minOrderMinor at 0, but a future
      // wire change must not start rendering a min-order chip on a package card.
      expect(
        offerMinOrderLine(_offer(
          'PACKAGE',
          const OfferTermsModel(packageId: 'pkg', packageNameEn: 'Gold', minOrderMinor: 10000),
        )),
        isNull,
      );
    });

    test('the card line and the detail line state the SAME threshold', () {
      final offer = _offer(
        'PROMO_CODE',
        const OfferTermsModel(promoCode: 'SAVE', discountType: 'FIXED_AMOUNT', configuredValue: 1500, minOrderMinor: 7550),
      );
      final card = offerMinOrderLine(offer)!;
      final detail = offerTermLines(offer, isAr: false)
          .firstWhere((l) => l.localeKey == LocaleKeys.offers_min_order);
      expect(card.args, detail.args);
      expect(card.args, ['75.50']);
    });
  });

  group('UCC23 step 6 / A5 — applicable services and zones', () {
    const restricted = OfferTermsModel(
      promoCode: 'CENTRAL',
      discountType: 'PERCENTAGE',
      configuredValue: 10,
      applicableServiceNamesAr: ['غسيل ممتاز', 'غسيل داخلي'],
      applicableServiceNamesEn: ['Premium Wash', 'Interior Wash'],
      applicableZoneNamesAr: ['وسط جدة'],
      applicableZoneNamesEn: ['Central Jeddah'],
    );

    test('a restricted code states both, after the discount and threshold', () {
      final lines = offerTermLines(_offer('PROMO_CODE', restricted), isAr: false);
      expect(lines, hasLength(3));
      expect(lines[0].localeKey, LocaleKeys.offers_discount_percent);
      expect(lines[1].localeKey, LocaleKeys.offers_applicable_services);
      expect(lines[1].args, ['Premium Wash, Interior Wash']);
      expect(lines[2].localeKey, LocaleKeys.offers_applicable_zones);
      expect(lines[2].args, ['Central Jeddah']);
    });

    test('Arabic reads the Arabic names', () {
      final lines = offerTermLines(_offer('PROMO_CODE', restricted), isAr: true);
      expect(lines[1].args, ['غسيل ممتاز، غسيل داخلي'],
          reason: 'the list separator is the Arabic comma, not the Latin one');
      expect(lines[2].args, ['وسط جدة']);
    });

    test('an EMPTY list is UNRESTRICTED — no line at all, not an empty one', () {
      final lines = offerTermLines(
        _offer(
          'PROMO_CODE',
          const OfferTermsModel(
            promoCode: 'ANY',
            discountType: 'PERCENTAGE',
            configuredValue: 10,
          ),
        ),
        isAr: false,
      );
      expect(lines.map((l) => l.localeKey),
          isNot(contains(LocaleKeys.offers_applicable_services)));
      expect(lines.map((l) => l.localeKey),
          isNot(contains(LocaleKeys.offers_applicable_zones)));
    });

    test('the zone line is stated regardless of any saved address', () {
      // A5 — "zone-dependent rules are skipped rather than failed; the offer is
      // shown with its zone terms stated". These lines are pure display data
      // computed from the offer alone, so no address state can suppress them.
      final lines = offerTermLines(_offer('PROMO_CODE', restricted), isAr: false);
      expect(lines.map((l) => l.localeKey),
          contains(LocaleKeys.offers_applicable_zones));
    });

    test('a PACKAGE offer states neither — its terms carry no scoping', () {
      final lines = offerTermLines(
        _offer(
          'PACKAGE',
          const OfferTermsModel(
            packageId: 'pkg',
            packageNameEn: 'Gold',
            applicableServiceNamesEn: ['Premium Wash'],
            applicableZoneNamesEn: ['Central Jeddah'],
          ),
        ),
        isAr: false,
      );
      expect(lines.map((l) => l.localeKey),
          isNot(contains(LocaleKeys.offers_applicable_services)));
      expect(lines.map((l) => l.localeKey),
          isNot(contains(LocaleKeys.offers_applicable_zones)));
    });
  });

  test('an all-zero terms object yields no lines at all', () {
    expect(offerTermLines(_offer('PACKAGE', const OfferTermsModel()), isAr: true), isEmpty);
    expect(offerTermLines(_offer('PROMO_CODE', const OfferTermsModel()), isAr: true), isEmpty);
  });
}
