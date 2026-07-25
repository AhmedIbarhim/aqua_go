import 'package:aqua_go/features/offers/data/models/customer_offer_model.dart';
import 'package:flutter_test/flutter_test.dart';

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
        'endsAt': '2026-12-31T20:59:59Z',
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
      expect(offer.endsAt, DateTime.utc(2026, 12, 31, 20, 59, 59));
      expect(offer.terms.promoCode, 'WELCOME15');
      expect(offer.terms.discountType, 'PERCENTAGE');
      expect(offer.terms.minOrderMinor, 5000);
      expect(offer.terms.packageId, isNull);
      // Package half defaults to 0, never null.
      expect(offer.terms.packageNumWashes, 0);
    });

    test('parses a PACKAGE offer with package terms', () {
      final offer = CustomerOfferModel.fromJson({
        'id': '018f-bbbb',
        'offerType': 'PACKAGE',
        'titleAr': 'باقة',
        'titleEn': 'Package',
        'descriptionAr': 'وصف',
        'descriptionEn': 'Desc',
        'endsAt': '2026-08-01T00:00:00Z',
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
  });
}
