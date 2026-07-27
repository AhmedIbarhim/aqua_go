import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/features/booking/domain/promo_code_history.dart';
import 'package:aqua_go/features/booking/domain/promo_code_rules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('promo code shape (UCC16 input field: 4-20 alphanumeric)', () {
    test('accepts a code of either case, at both length bounds', () {
      expect(isWellFormedPromoCode('WELCOME20'), isTrue);
      expect(isWellFormedPromoCode('welcome20'), isTrue);
      expect(isWellFormedPromoCode('ABCD'), isTrue);
      expect(isWellFormedPromoCode('A' * 20), isTrue);
    });

    test('trims before judging, so a pasted code with spaces is usable', () {
      expect(isWellFormedPromoCode('  WELCOME20 '), isTrue);
    });

    test('refuses anything outside the bounds or with punctuation', () {
      expect(isWellFormedPromoCode(''), isFalse);
      expect(isWellFormedPromoCode('ABC'), isFalse);
      expect(isWellFormedPromoCode('A' * 21), isFalse);
      expect(isWellFormedPromoCode('WELCOME-20'), isFalse);
      expect(isWellFormedPromoCode('WELCOME 20'), isFalse);
      expect(isWellFormedPromoCode('https://x.co/WELCOME20'), isFalse);
      expect(isWellFormedPromoCode('ترحيب20'), isFalse);
    });
  });

  group('previously used codes', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await CacheClient.init();
    });

    test('starts empty', () {
      expect(PromoCodeHistory.recent(), isEmpty);
    });

    test('most recent first', () async {
      await PromoCodeHistory.remember('FIRST1');
      await PromoCodeHistory.remember('SECOND2');

      expect(PromoCodeHistory.recent(), ['SECOND2', 'FIRST1']);
    });

    test('re-using a code moves it to the front instead of repeating it', () async {
      await PromoCodeHistory.remember('FIRST1');
      await PromoCodeHistory.remember('SECOND2');
      await PromoCodeHistory.remember('first1');

      expect(PromoCodeHistory.recent(), ['FIRST1', 'SECOND2']);
    });

    test('normalises to upper case, the way the server stores it', () async {
      await PromoCodeHistory.remember(' welcome20 ');

      expect(PromoCodeHistory.recent(), ['WELCOME20']);
    });

    test('keeps only the most recent few', () async {
      for (var i = 0; i < PromoCodeHistory.maxEntries + 3; i++) {
        await PromoCodeHistory.remember('CODE$i');
      }

      final recent = PromoCodeHistory.recent();
      expect(recent.length, PromoCodeHistory.maxEntries);
      expect(recent.first, 'CODE${PromoCodeHistory.maxEntries + 2}');
      expect(recent.contains('CODE0'), isFalse);
    });
  });
}
