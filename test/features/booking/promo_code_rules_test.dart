import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/features/auth/data/models/user_model.dart';
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
    // The store is keyed by the signed-in customer's local id, so these tests
    // need somebody signed in. `signIn` writes the same cached-user record the
    // app writes, which is also what the session teardown removes.
    Future<void> signIn(String customerId) async {
      await CacheClient.setString(
        kUserData,
        UserModel(id: customerId).toEncodedJson(),
      );
    }

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await CacheClient.init();
      await signIn('customer-a');
    });

    test('starts empty', () {
      expect(PromoCodeHistory.recent(), isEmpty);
    });

    /// The defect this closes: one unscoped key meant the next person to sign
    /// in on a shared handset was offered the previous customer's codes.
    test('one customer is never offered another customer\'s codes', () async {
      await PromoCodeHistory.remember('ACODE1');

      await signIn('customer-b');
      expect(PromoCodeHistory.recent(), isEmpty);

      await PromoCodeHistory.remember('BCODE2');
      expect(PromoCodeHistory.recent(), ['BCODE2']);

      await signIn('customer-a');
      expect(PromoCodeHistory.recent(), ['ACODE1']);
    });

    test('a signed-out viewer has no history and records none', () async {
      await PromoCodeHistory.remember('ACODE1');
      await CacheClient.removeString(kUserData);

      expect(PromoCodeHistory.recent(), isEmpty);
      await PromoCodeHistory.remember('GUEST1');
      expect(PromoCodeHistory.recent(), isEmpty);
    });

    /// Account DELETION erases it — a PDPL obligation, not a nicety: the
    /// account is gone server-side, so nothing of it may sit on the handset.
    test(
      'forget erases this customer, and the pre-scoping store too',
      () async {
        await CacheClient.setStringList(
          PromoCodeHistory.legacyStorageKey,
          const ['LEGACY1'],
        );
        await PromoCodeHistory.remember('ACODE1');

        await PromoCodeHistory.forget();

        expect(PromoCodeHistory.recent(), isEmpty);
        expect(
          CacheClient.getStringList(PromoCodeHistory.legacyStorageKey),
          isEmpty,
        );
      },
    );

    /// An ordinary sign-out is NOT an erasure. UCC16 asks for "autocomplete of
    /// previously used codes"; wiping the store whenever the session ends would
    /// make that last one session and hand a returning customer nothing. The
    /// per-customer key is what makes keeping it safe — the test above proves
    /// nobody else can read it. What DOES go is the pre-scoping shared store an
    /// older build could have left behind.
    test(
      'the ordinary teardown keeps the customer\'s codes and drops the legacy store',
      () async {
        await CacheClient.setStringList(
          PromoCodeHistory.legacyStorageKey,
          const ['LEGACY1'],
        );
        await PromoCodeHistory.remember('ACODE1');

        await PromoCodeHistory.forgetLegacyDeviceStore();

        expect(PromoCodeHistory.recent(), ['ACODE1']);
        expect(
          CacheClient.getStringList(PromoCodeHistory.legacyStorageKey),
          isEmpty,
        );
      },
    );

    test('most recent first', () async {
      await PromoCodeHistory.remember('FIRST1');
      await PromoCodeHistory.remember('SECOND2');

      expect(PromoCodeHistory.recent(), ['SECOND2', 'FIRST1']);
    });

    test(
      're-using a code moves it to the front instead of repeating it',
      () async {
        await PromoCodeHistory.remember('FIRST1');
        await PromoCodeHistory.remember('SECOND2');
        await PromoCodeHistory.remember('first1');

        expect(PromoCodeHistory.recent(), ['FIRST1', 'SECOND2']);
      },
    );

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
