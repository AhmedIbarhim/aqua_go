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

/// The locale key a row renders from, or null when the row is a literal. The
/// hierarchy is sealed, so this is a total function rather than a nullable-field
/// read — and a test that asks a literal for its key gets null, not a crash.
String? _key(OfferTermLine line) => line is OfferTermKey ? line.key : null;

/// The positional args a row renders with; empty for a literal row.
List<String> _args(OfferTermLine line) =>
    line is OfferTermKey ? line.args : const <String>[];

/// The already-localised text of a literal row, or null for a keyed one.
String? _text(OfferTermLine line) =>
    line is OfferTermLiteral ? line.text : null;

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
    expect(_key(lines[0]), LocaleKeys.offers_discount_percent);
    expect(_args(lines[0]), ['15']);
    expect(_key(lines[1]), LocaleKeys.offers_min_order);
    expect(_args(lines[1]), ['50.00']);
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
    expect(_key(lines[0]), LocaleKeys.offers_discount_amount);
    expect(_args(lines[0]), ['20.00']);
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
    expect(_text(en[0]), 'Gold package');
    expect(_key(en[1]), LocaleKeys.offers_package_washes);
    expect(_key(en[2]), LocaleKeys.offers_package_validity);
    expect(_key(en[3]), LocaleKeys.offers_package_price);
    expect(_args(en[3]), ['249.00']);

    final ar = offerTermLines(_offer('PACKAGE', terms), isAr: true);
    expect(_text(ar[0]), 'الباقة الذهبية');
  });

  group('offerMinOrderLine — BR-OFR-10 / AC-EXT-06 in the DETAIL view', () {
    test('a promo offer carrying a minimum order states the threshold', () {
      // AC-EXT-06: "an offer carrying a minimum order value is shown, with the
      // SAR 100 threshold stated". Since §1.5b the card is its artwork and
      // nothing else, so the detail view is where it is stated in text.
      final line = offerMinOrderLine(_offer(
        'PROMO_CODE',
        const OfferTermsModel(promoCode: 'SAVE', discountType: 'PERCENTAGE', configuredValue: 20, minOrderMinor: 10000),
      ));
      expect(line, isNotNull);
      expect(line!.key, LocaleKeys.offers_min_order);
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
      // wire change must not start printing a threshold under a package offer,
      // which has no minimum to meet.
      expect(
        offerMinOrderLine(_offer(
          'PACKAGE',
          const OfferTermsModel(packageId: 'pkg', packageNameEn: 'Gold', minOrderMinor: 10000),
        )),
        isNull,
      );
    });

    test('the helper and the rendered terms block state the SAME threshold', () {
      // The helper is reachable on its own, so it has to keep agreeing with the
      // row `offerTermLines` actually emits — a divergence would put two
      // different numbers behind one requirement.
      final offer = _offer(
        'PROMO_CODE',
        const OfferTermsModel(promoCode: 'SAVE', discountType: 'FIXED_AMOUNT', configuredValue: 1500, minOrderMinor: 7550),
      );
      final helper = offerMinOrderLine(offer)!;
      final rendered = offerTermLines(offer, isAr: false)
          .whereType<OfferTermKey>()
          .firstWhere((l) => l.key == LocaleKeys.offers_min_order);
      expect(helper.args, rendered.args);
      expect(helper.args, ['75.50']);
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
      expect(_key(lines[0]), LocaleKeys.offers_discount_percent);
      expect(_key(lines[1]), LocaleKeys.offers_applicable_services);
      expect(_args(lines[1]), ['Premium Wash, Interior Wash']);
      expect(_key(lines[2]), LocaleKeys.offers_applicable_zones);
      expect(_args(lines[2]), ['Central Jeddah']);
    });

    test('Arabic reads the Arabic names', () {
      final lines = offerTermLines(_offer('PROMO_CODE', restricted), isAr: true);
      expect(_args(lines[1]), ['غسيل ممتاز، غسيل داخلي'],
          reason: 'the list separator is the Arabic comma, not the Latin one');
      expect(_args(lines[2]), ['وسط جدة']);
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
      expect(lines.map(_key),
          isNot(contains(LocaleKeys.offers_applicable_services)));
      expect(lines.map(_key),
          isNot(contains(LocaleKeys.offers_applicable_zones)));
    });

    test('the zone line is stated regardless of any saved address', () {
      // A5 — "zone-dependent rules are skipped rather than failed; the offer is
      // shown with its zone terms stated". These lines are pure display data
      // computed from the offer alone, so no address state can suppress them.
      final lines = offerTermLines(_offer('PROMO_CODE', restricted), isAr: false);
      expect(lines.map(_key),
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
      expect(lines.map(_key),
          isNot(contains(LocaleKeys.offers_applicable_services)));
      expect(lines.map(_key),
          isNot(contains(LocaleKeys.offers_applicable_zones)));
    });
  });

  test('an all-zero terms object yields no lines at all', () {
    expect(offerTermLines(_offer('PACKAGE', const OfferTermsModel()), isAr: true), isEmpty);
    expect(offerTermLines(_offer('PROMO_CODE', const OfferTermsModel()), isAr: true), isEmpty);
  });
}
