import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/promo_summary_harness.dart';

/// Regression cover for the price-lock re-quote on `BookingSummaryView`.
///
/// The 15-minute quote TTL can expire while the customer sits on the summary
/// screen. Confirm then re-quotes before charging and aborts when the total
/// moved. That refresh MUST carry the applied promo: `BookingCubit.fetchQuote`
/// forwards only what its caller hands it, so the refresh goes through
/// `reprice()`, which re-sends the promo held on the state. Quoting bare
/// re-prices at the undiscounted price, which silently drops the discount AND
/// makes the gross comparison fail forever, so the booking can never be
/// completed while a promo is applied.
void main() {
  const promoCode = 'WELCOME15';

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await CacheClient.init();
    await EasyLocalization.ensureInitialized();
    await loadTranslations();
  });

  testWidgets('expired-quote refresh re-sends the applied promo code', (
    tester,
  ) async {
    final repo = RecordingBookingRepo();
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);

    await pumpSummary(tester, cubit);

    // Initial mount quote — no promo yet.
    expect(repo.quoteCalls, [null]);

    await applyPromo(tester, promoCode);

    // The applied quote is the discounted one and it is already expired.
    expect(repo.quoteCalls, [null, promoCode]);
    expect(
      cubit.pricing.state.quote!.breakdown!.grossMinor,
      grossWithPromoMinor,
    );

    await tapConfirm(tester);

    // THE INVARIANT: the price-lock refresh carried the applied promo code.
    expect(
      repo.quoteCalls,
      [null, promoCode, promoCode],
      reason:
          'the expired-quote refresh must re-quote WITH the applied promo code',
    );
    // Same total back → no "prices refreshed" abort, the charge proceeds.
    expect(
      repo.paymentInitCalls,
      1,
      reason:
          'an unchanged discounted total must let the payment attempt proceed',
    );
  });

  testWidgets('expired-quote refresh sends no promo when none is applied', (
    tester,
  ) async {
    final repo = RecordingBookingRepo();
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);

    await pumpSummary(tester, cubit);
    expect(repo.quoteCalls, [null]);
    expect(
      cubit.pricing.state.quote!.breakdown!.grossMinor,
      grossWithoutPromoMinor,
    );

    await tapConfirm(tester);

    expect(repo.quoteCalls, [null, null]);
    expect(repo.paymentInitCalls, 1);
  });
}
