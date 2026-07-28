import 'package:aqua_go/features/offers/data/models/customer_offer_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every `endsAt` fixture here is a BARE Asia/Riyadh wall clock — no offset, no
/// trailing `Z`. That is the only shape the backend emits
/// (`SaudiTimeSerializers`), and encoding anything else here is what let the
/// device-local parse bug survive: under a `Z`-suffixed fixture `DateTime.parse`
/// happens to return a genuine UTC instant and the defect is invisible.
///
/// The parsed value lands in the Riyadh frame — UTC-flagged, carrying the
/// wall-clock fields verbatim — so `DateTime.utc(...)` is the correct
/// expectation, and `DateTime` equality checks both the instant AND the flag.
void main() {
  group('CustomerOfferModel.fromJson', () {
    test('parses a PROMO_CODE offer with promo terms', () {
      final json = {
        'id': '018f-aaaa',
        'offerType': 'PROMO_CODE',
        'titleAr': 'خصم الترحيب',
        'titleEn': 'Welcome discount',
        'descriptionAr': 'وصف عربي',
        'descriptionEn': 'English description',
        'bannerArUrl': 'https://cdn/ar.jpg',
        'bannerEnUrl': 'https://cdn/en.jpg',
        'endsAt': '2026-12-31T23:59:59',
        'terms': {
          'promoCode': 'WELCOME15',
          'discountType': 'PERCENTAGE',
          'configuredValue': 15,
          'minOrderMinor': 5000,
        },
      };
      final offer = CustomerOfferModel.fromJson(json);
      expect(offer.id, '018f-aaaa');
      expect(offer.offerType, 'PROMO_CODE');
      expect(offer.isPromoCode, isTrue);
      expect(offer.titleAr, 'خصم الترحيب');
      expect(offer.bannerEnUrl, 'https://cdn/en.jpg');
      expect(offer.endsAt, DateTime.utc(2026, 12, 31, 23, 59, 59));
      expect(offer.terms.promoCode, 'WELCOME15');
      expect(offer.terms.discountType, 'PERCENTAGE');
      expect(offer.terms.minOrderMinor, 5000);
      expect(offer.terms.packageId, isNull);
      // Package half defaults to 0, never null.
      expect(offer.terms.packageNumWashes, 0);
    });

    test('parses the applicable service and zone names, per language', () {
      // UCC23 step 6 — "terms (… applicable services, applicable zones …)".
      // OfferTerms publishes them as bilingual NAMES, index-aligned and equal
      // in length, so a client picks its locale's list positionally.
      final offer = CustomerOfferModel.fromJson({
        'id': '018f-cccc',
        'offerType': 'PROMO_CODE',
        'titleAr': 'ع',
        'titleEn': 'T',
        'descriptionAr': 'و',
        'descriptionEn': 'D',
        'endsAt': '2026-12-31T23:59:59',
        'terms': {
          'promoCode': 'CENTRAL',
          'discountType': 'PERCENTAGE',
          'configuredValue': 10,
          'applicableServiceNamesAr': ['غسيل ممتاز', 'غسيل داخلي'],
          'applicableServiceNamesEn': ['Premium Wash', 'Interior Wash'],
          'applicableZoneNamesAr': ['وسط جدة'],
          'applicableZoneNamesEn': ['Central Jeddah'],
        },
      });
      expect(offer.terms.applicableServices(isAr: false),
          ['Premium Wash', 'Interior Wash']);
      expect(offer.terms.applicableServices(isAr: true),
          ['غسيل ممتاز', 'غسيل داخلي']);
      expect(offer.terms.applicableZones(isAr: false), ['Central Jeddah']);
      expect(offer.terms.applicableZones(isAr: true), ['وسط جدة']);
    });

    test('absent restriction lists read as UNRESTRICTED, not as null', () {
      // An empty list means the code is valid everywhere — never "applies to
      // nothing" — so the read path must not make callers null-check it.
      final offer = CustomerOfferModel.fromJson({
        'id': '018f-dddd',
        'offerType': 'PROMO_CODE',
        'titleAr': 'ع',
        'titleEn': 'T',
        'descriptionAr': 'و',
        'descriptionEn': 'D',
        'endsAt': '2026-12-31T23:59:59',
        'terms': {'promoCode': 'ANY', 'discountType': 'PERCENTAGE'},
      });
      expect(offer.terms.applicableServices(isAr: false), isEmpty);
      expect(offer.terms.applicableZones(isAr: true), isEmpty);
    });

    test('a non-list restriction payload degrades to empty, never throws', () {
      final offer = CustomerOfferModel.fromJson({
        'id': '018f-eeee',
        'offerType': 'PROMO_CODE',
        'titleAr': 'ع',
        'titleEn': 'T',
        'descriptionAr': 'و',
        'descriptionEn': 'D',
        'endsAt': '2026-12-31T23:59:59',
        'terms': {
          'promoCode': 'ANY',
          'applicableServiceNamesEn': 'Premium Wash',
          'applicableZoneNamesEn': 42,
        },
      });
      expect(offer.terms.applicableServices(isAr: false), isEmpty);
      expect(offer.terms.applicableZones(isAr: false), isEmpty);
    });

    test('parses a PACKAGE offer with package terms', () {
      final offer = CustomerOfferModel.fromJson({
        'id': '018f-bbbb',
        'offerType': 'PACKAGE',
        'titleAr': 'باقة',
        'titleEn': 'Package',
        'descriptionAr': 'وصف',
        'descriptionEn': 'Desc',
        'endsAt': '2026-08-01T00:00:00',
        'terms': {
          'packageId': '018f-pkg',
          'packageNameAr': 'الباقة الذهبية',
          'packageNameEn': 'Gold package',
          'packagePriceMinor': 24900,
          'packageNumWashes': 8,
          'packageValidityDays': 30,
        },
      });
      expect(offer.isPromoCode, isFalse);
      expect(offer.bannerArUrl, isNull);
      expect(offer.terms.packageId, '018f-pkg');
      expect(offer.terms.packageNumWashes, 8);
      expect(offer.terms.packagePriceMinor, 24900);
      expect(offer.terms.packageName(isAr: true), 'الباقة الذهبية');
      expect(offer.terms.packageName(isAr: false), 'Gold package');
      // Promo half is absent, so the discount branch renders nothing.
      expect(offer.terms.discountType, isNull);
      expect(offer.terms.configuredValue, 0);
    });

    test('a missing terms object and a missing endsAt never throw', () {
      final offer = CustomerOfferModel.fromJson({
        'id': 'x',
        'offerType': 'PACKAGE',
        'titleAr': 'a',
        'titleEn': 'b',
        'descriptionAr': 'c',
        'descriptionEn': 'd',
      });
      expect(offer.terms.promoCode, isNull);
      expect(offer.terms.minOrderMinor, 0);
      expect(offer.endsAt, DateTime.utc(9999, 12, 31));
    });

    test('an unparseable endsAt falls back instead of throwing', () {
      final offer = CustomerOfferModel.fromJson({
        'id': 'x',
        'offerType': 'PACKAGE',
        'titleAr': 'a',
        'titleEn': 'b',
        'descriptionAr': 'c',
        'descriptionEn': 'd',
        'endsAt': 'not-a-date',
      });
      expect(offer.endsAt, DateTime.utc(9999, 12, 31));
    });

    test('title/description/banner resolve by locale flag', () {
      final offer = CustomerOfferModel.fromJson({
        'id': 'x',
        'offerType': 'PACKAGE',
        'titleAr': 'عنوان',
        'titleEn': 'Title',
        'descriptionAr': 'وصف',
        'descriptionEn': 'Description',
      });
      expect(offer.title(isAr: true), 'عنوان');
      expect(offer.title(isAr: false), 'Title');
      expect(offer.description(isAr: true), 'وصف');
      expect(offer.banner(isAr: true), isNull);
    });

    test('parses a SERVICE offer carrying a target-price deal', () {
      final offer = CustomerOfferModel.fromJson({
        'id': '018f-dddd',
        'offerType': 'SERVICE',
        'titleAr': 'غسيل كامل بـ 35',
        'titleEn': 'Full wash for 35',
        'descriptionAr': 'وصف',
        'descriptionEn': 'Description',
        // Bare Asia/Riyadh wall clock — no offset, no trailing Z.
        'endsAt': '2026-08-31T21:59:59',
        'terms': {
          'serviceId': 'svc-1',
          'serviceNameAr': 'غسيل كامل',
          'serviceNameEn': 'Full wash',
          'serviceListPriceMinor': 17500,
          'targetPriceMinor': 3500,
        },
      });
      expect(offer.offerType, 'SERVICE');
      expect(offer.isService, isTrue);
      expect(offer.isPromoCode, isFalse);
      expect(offer.endsAt, DateTime.utc(2026, 8, 31, 21, 59, 59));
      expect(offer.terms.serviceId, 'svc-1');
      expect(offer.terms.serviceNameAr, 'غسيل كامل');
      expect(offer.terms.serviceNameEn, 'Full wash');
      expect(offer.terms.serviceListPriceMinor, 17500);
      expect(offer.terms.targetPriceMinor, 3500);
      expect(offer.hasTargetPrice, isTrue);
    });

    test('a SHORTCUT service offer has a zero target and no deal', () {
      // A SERVICE offer may carry no deal at all — it is then a pure shortcut
      // card that jumps into booking the wash at its list price. 0 means
      // "nothing to show", NOT a free wash, which is exactly why callers must
      // ask `hasTargetPrice` rather than testing the number themselves.
      final offer = CustomerOfferModel.fromJson({
        'id': '018f-eeee',
        'offerType': 'SERVICE',
        'titleAr': 'احجز غسيل كامل',
        'titleEn': 'Book a full wash',
        'descriptionAr': 'وصف',
        'descriptionEn': 'Description',
        'endsAt': '2026-08-31T21:59:59',
        'terms': {
          'serviceId': 'svc-1',
          'serviceNameAr': 'غسيل كامل',
          'serviceNameEn': 'Full wash',
          'serviceListPriceMinor': 17500,
          'targetPriceMinor': 0,
        },
      });
      expect(offer.isService, isTrue);
      expect(offer.terms.targetPriceMinor, 0);
      expect(offer.hasTargetPrice, isFalse);
      // The list price is still there — a shortcut card can still say what the
      // wash costs.
      expect(offer.terms.serviceListPriceMinor, 17500);
    });

    test('hasTargetPrice is false for a non-SERVICE offer, whatever the terms', () {
      // Defensive: `targetPriceMinor` is documented as 0 on the other two
      // types, but a client must not start discounting a PROMO_CODE card if a
      // future server ever sends one.
      final offer = CustomerOfferModel.fromJson({
        'id': 'x',
        'offerType': 'PROMO_CODE',
        'titleAr': 'a',
        'titleEn': 'b',
        'descriptionAr': 'c',
        'descriptionEn': 'd',
        'terms': {'promoCode': 'WELCOME', 'targetPriceMinor': 3500},
      });
      expect(offer.isService, isFalse);
      expect(offer.hasTargetPrice, isFalse);
    });

    test('a partial SERVICE terms payload degrades rather than throwing', () {
      // Read-reconstruction path: it must never tighten into a failure. An
      // absent service half is all-null identity + all-zero numbers, exactly
      // like the promo and package halves.
      final offer = CustomerOfferModel.fromJson({
        'id': 'x',
        'offerType': 'SERVICE',
        'titleAr': 'a',
        'titleEn': 'b',
        'descriptionAr': 'c',
        'descriptionEn': 'd',
        'terms': {'serviceId': 'svc-1'},
      });
      expect(offer.terms.serviceId, 'svc-1');
      expect(offer.terms.serviceNameAr, isNull);
      expect(offer.terms.serviceNameEn, isNull);
      expect(offer.terms.serviceListPriceMinor, 0);
      expect(offer.terms.targetPriceMinor, 0);
      expect(offer.hasTargetPrice, isFalse);
    });

    test('the service name resolves by locale flag', () {
      final offer = CustomerOfferModel.fromJson({
        'id': 'x',
        'offerType': 'SERVICE',
        'titleAr': 'a',
        'titleEn': 'b',
        'descriptionAr': 'c',
        'descriptionEn': 'd',
        'terms': {
          'serviceId': 'svc-1',
          'serviceNameAr': 'غسيل كامل',
          'serviceNameEn': 'Full wash',
        },
      });
      expect(offer.terms.serviceName(isAr: true), 'غسيل كامل');
      expect(offer.terms.serviceName(isAr: false), 'Full wash');
    });
  });
}
