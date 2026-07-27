import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:aqua_go/features/booking/data/models/quote_model.dart';
import 'package:aqua_go/features/booking/presentation/widgets/payment_summary_card.dart';
import 'package:aqua_go/generated/codegen_loader.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locks the invariant PaymentSummaryCard depends on: the backend quote
/// breakdown is ALREADY net of any applied promo, so Subtotal + VAT == Total
/// with `promoDiscountMinor` playing NO part in the arithmetic. The second
/// test spells out exactly how far off the column would be if someone
/// reintroduced a `-promoDiscount` row between Subtotal and VAT.
///
/// The render group below covers the other half: that the rows the promo adds
/// actually FIT. `promo_summary_harness` deliberately pumps the whole summary
/// screen on a 1400pt canvas so its behaviour tests are not layout tests, which
/// means no test there can ever see a phone-width overflow — so the card is
/// pumped here on its own, at a real device size, in Arabic.
void main() {
  group('promo-applied quote breakdown', () {
    // Base gross 11500 minor, promo 2000 minor, 15% VAT-inclusive:
    // discountedGross 9500 -> vat 1239, net 8261.
    final promoQuote = QuoteModel.fromJson({
      'quoteId': 'q-promo-1',
      'totalMinor': 9500,
      'vatMinor': 1239,
      'currency': 'SAR',
      // Bare Asia/Riyadh local — the only shape the backend emits. A `Z` here
      // would send `QuoteModel.fromJson` down the anchored branch the server
      // never produces, hiding the device-local parse it is guarded against.
      'expiresAt': '2026-07-24T10:00:00',
      'promoCode': 'WELCOME15',
      'promoDiscountMinor': 2000,
      'breakdown': {
        'grossMinor': 9500,
        'netMinor': 8261,
        'vatMinor': 1239,
        'currency': 'SAR',
      },
    });

    test('subtotal + vat reconciles to total with no discount row', () {
      final b = promoQuote.breakdown!;
      expect(b.netMinor! + b.vatMinor!, b.grossMinor);
      expect(b.net + b.vat, closeTo(b.gross, 0.001));
    });

    test('subtracting the promo a second time breaks the column', () {
      final b = promoQuote.breakdown!;
      final doubleSubtracted =
          b.netMinor! - promoQuote.promoDiscountMinor + b.vatMinor!;
      expect(doubleSubtracted, isNot(b.grossMinor));
      expect(doubleSubtracted, 7500);
    });
  });

  group('the card fits a phone', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await EasyLocalization.ensureInitialized();
    });

    testWidgets('the widest Arabic shape — add-on, promo rows and all', (
      tester,
    ) async {
      // The two rows UCC16 step 4 adds carry the longest labels on the card
      // ("الإجمالي قبل الخصم", "خصم الكود"), and the row helper was two
      // unbounded `Text`s in a spaceBetween Row. No RTL special-handling
      // anywhere — the same widget is pumped, in ar.
      await _pumpCard(
        tester,
        const PaymentSummaryCard(
          serviceName: 'غسيل خارجي وداخلي شامل تلميع الإطارات',
          servicePrice: 62.61,
          additionalItems: [
            {
              'name': 'تلميع الإطارات وتنظيف المقصورة الداخلية بالبخار',
              'price': 20.0,
            },
          ],
          subtotal: 82.61,
          vat: 12.39,
          total: 95.0,
          promoDiscount: 20.0,
        ),
      );

      expect(find.text('الإجمالي قبل الخصم'), findsOneWidget);
      expect(find.text('خصم الكود'), findsOneWidget);
      expect(find.text('-20.00'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('and with no promo applied', (tester) async {
      await _pumpCard(
        tester,
        const PaymentSummaryCard(
          serviceName: 'غسيل خارجي وداخلي شامل تلميع الإطارات',
          servicePrice: 100.0,
          additionalItems: [],
          subtotal: 100.0,
          vat: 15.0,
          total: 115.0,
        ),
      );

      expect(find.text('الإجمالي قبل الخصم'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Pumps [card] at a real phone width, not the 800x600 test default — 800pt
/// hides every overflow a spaceBetween row can have.
Future<void> _pumpCard(WidgetTester tester, PaymentSummaryCard card) async {
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      saveLocale: false,
      assetLoader: const CodegenLoader(),
      child: Builder(
        builder: (context) => MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          theme: ThemeData(
            extensions: <ThemeExtension<dynamic>>[darkAppColors],
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                // The screen wraps the card in a 6%-of-width page padding.
                padding: const EdgeInsets.symmetric(horizontal: 22.5),
                child: card,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}
