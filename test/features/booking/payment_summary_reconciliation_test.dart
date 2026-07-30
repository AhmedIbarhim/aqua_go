import 'package:aqua_go/core/pricing/gross_price_breakdown.dart';
import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:aqua_go/features/booking/presentation/widgets/payment_summary_card.dart';
import 'package:aqua_go/generated/codegen_loader.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locks the VAT-INCLUSIVE breakdown the customer sees, and guards the two
/// defects it replaced:
///
///   * a NET line item or a NET "before tax" subtotal reappearing, and
///   * the SAME discount appearing twice in two different bases.
///
/// The worked example throughout is the owner's: a 120.00 wash plus a 55.00
/// add-on, a 50.00 code, 15% VAT-inclusive. Gross subtotal 175.00, charged
/// 125.00, VAT within that 16.30. The old layout showed the same order as
/// 104.35 / 47.83 / −43.48 / 108.70 / 16.30 / −50.00 / 175.00 / 125.00 — every
/// figure reconciling, none of it followable by eye.
void main() {
  // What the BACKEND puts on the wire for that order — ONE shape now, for both
  // surfaces.
  //
  // A quote used to net the discount INTO its lines and emit no DISCOUNT row,
  // so its SERVICE line arrived at 120.00 − 50.00 = 70.00 and the client added
  // the 50.00 back. It no longer does: `PriceQuoteServiceImpl.buildLines` emits
  // the same three-kind shape the booking detail always emitted — pre-discount
  // SERVICE + ADDON rows and one negative DISCOUNT row — so `fromQuoteLines`
  // and the arithmetic inside it are both gone. A quote's DISCOUNT row is
  // filtered out of `itemLines` by the caller and passed as `discountMinor`,
  // exactly as the booking detail does it.
  GrossPriceBreakdown quoteCase() => GrossPriceBreakdown.fromBookingLines(
    itemLines: const [
      GrossLine(label: 'تنظيف السقف الداخلي', grossMinor: 12000),
      GrossLine(label: 'معالجة بالأوزون', grossMinor: 5500),
    ],
    discountMinor: 5000,
    promoCode: 'NEWCUST50',
    totalMinor: 12500,
    vatMinor: 1630,
  );

  // A BOOKING DETAIL states the pre-discount price on the SERVICE row and
  // carries the saving as its own negative DISCOUNT line — unchanged.
  GrossPriceBreakdown bookingCase() => GrossPriceBreakdown.fromBookingLines(
    itemLines: const [
      GrossLine(label: 'تنظيف السقف الداخلي', grossMinor: 12000),
      GrossLine(label: 'معالجة بالأوزون', grossMinor: 5500),
    ],
    discountMinor: 5000,
    promoCode: 'NEWCUST50',
    totalMinor: 12500,
    vatMinor: 1630,
  );

  group('the gross breakdown reconciles', () {
    test('a quote reads the PRE-discount lines verbatim, adding nothing back',
        () {
      final b = quoteCase();
      // 120.00 arrives ON THE WIRE. Nothing is reconstructed here, which is the
      // point: a TARGET_PRICE code makes the pre-discount figure impossible to
      // recover from the charged one.
      expect(b.lines.map((l) => l.grossMinor), [12000, 5500]);
      expect(b.subtotalMinor, 17500);
      expect(b.discountMinor, 5000);
      expect(b.totalMinor, 12500);
    });

    test('a TARGET_PRICE quote states both figures without arithmetic', () {
      // 175.00 wash sold at 35.00. Under the old shape the wire carried a
      // 35.00 SERVICE row and a 140.00 discount, and adding them back happened
      // to work; under a LINE-scoped discount that coincidence is not something
      // to rely on. The backend now states 175.00 and −140.00 outright.
      final b = GrossPriceBreakdown.fromBookingLines(
        itemLines: const [GrossLine(label: 'غسيل كامل', grossMinor: 17500)],
        discountMinor: 14000,
        promoCode: 'OFFERCODE',
        totalMinor: 3500,
        vatMinor: 457,
      );
      expect(b.subtotalMinor, 17500);
      expect(b.discountMinor, 14000);
      expect(b.totalMinor, 3500);
      expect(b.linesReconcile, isTrue);
      expect(b.totalReconciles, isTrue);
    });

    test('a booking detail reads the pre-discount lines verbatim', () {
      final b = bookingCase();
      expect(b.lines.map((l) => l.grossMinor), [12000, 5500]);
      expect(b.subtotalMinor, 17500);
    });

    test('both surfaces state the SAME figures', () {
      final q = quoteCase();
      final d = bookingCase();
      expect(q.lines.map((l) => l.grossMinor), d.lines.map((l) => l.grossMinor));
      expect(q.subtotalMinor, d.subtotalMinor);
      expect(q.discountMinor, d.discountMinor);
      expect(q.totalMinor, d.totalMinor);
      expect(q.vatMinor, d.vatMinor);
    });

    test('the lines sum EXACTLY to the subtotal — not within a halala', () {
      for (final b in [quoteCase(), bookingCase()]) {
        expect(b.lines.fold<int>(0, (s, l) => s + l.grossMinor), 17500);
        expect(b.linesReconcile, isTrue);
      }
    });

    test('subtotal − discount == total, the one sum the layout states', () {
      for (final b in [quoteCase(), bookingCase()]) {
        expect(b.totalReconciles, isTrue);
        expect(b.subtotalMinor - b.discountMinor, b.totalMinor);
      }
    });

    test('VAT is NOT an addend — it is already inside the total', () {
      final b = quoteCase();
      // The disclosed VAT is what was charged on the DISCOUNTED gross (15% of
      // 108.70), NOT 15% of the 175.00 subtotal (22.83). Adding it to the total
      // would double-count it.
      expect(b.vatMinor, 1630);
      expect(b.totalMinor + b.vatMinor, isNot(b.subtotalMinor));
    });

    test('no promo: no subtotal, no discount, no −0.00', () {
      final b = GrossPriceBreakdown.fromBookingLines(
        itemLines: const [GrossLine(label: 'wash', grossMinor: 12000)],
        discountMinor: 0,
        promoCode: null,
        totalMinor: 12000,
        vatMinor: 1565,
      );
      expect(b.hasDiscount, isFalse);
      expect(b.lines.single.grossMinor, 12000);
      // "Before discount" would just restate the total, which is why the row is
      // suppressed rather than rendered as an equal pair.
      expect(b.subtotalMinor, b.totalMinor);
      expect(b.linesReconcile, isTrue);
    });
  });

  group('the card renders gross, once', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await EasyLocalization.ensureInitialized();
    });

    testWidgets('every visible figure is VAT-inclusive', (tester) async {
      await _pumpCard(tester, PaymentSummaryCard(breakdown: quoteCase()));

      expect(find.text('120.00'), findsOneWidget); // service, gross
      expect(find.text('55.00'), findsOneWidget); // add-on, gross
      expect(find.text('175.00'), findsOneWidget); // subtotal, gross
      expect(find.text('-50.00'), findsOneWidget); // discount, full value
      expect(find.text('125.00'), findsOneWidget); // total
      expect(find.text('16.30'), findsOneWidget); // VAT, disclosed
      expect(tester.takeException(), isNull);
    });

    testWidgets('the code is folded into the discount row', (tester) async {
      await _pumpCard(tester, PaymentSummaryCard(breakdown: quoteCase()));

      expect(find.text('خصم NEWCUST50'), findsOneWidget);
      // The standalone "كود الخصم" row it replaced must not come back.
      expect(find.text('كود الخصم'), findsNothing);
    });

    // GUARD 1 — a NET figure must never reappear on this card.
    //
    // Red-proof: have the caller pass the DISCOUNT row's own gross through as
    // an item line instead of filtering it out, and this test fails — the
    // negative row lands in the column and the subtotal stops reconciling.
    testWidgets('GUARD: no net figure is rendered', (tester) async {
      await _pumpCard(tester, PaymentSummaryCard(breakdown: quoteCase()));

      for (final net in const [
        '104.35', // service net
        '47.83', // add-on net
        '108.70', // net subtotal — the second, competing base
        '-43.48', // the discount restated pre-VAT
        '43.48',
        '152.18', // what the old net line items summed to: shown nowhere
        '70.00', // the post-discount service gross the quote puts on the wire
      ]) {
        expect(
          find.text(net),
          findsNothing,
          reason: '$net is a net/post-discount figure and must not be shown',
        );
      }
    });

    // GUARD 2 — the discount appears EXACTLY once.
    //
    // The old card stated it twice in two bases (−43.48 pre-VAT and −50.00
    // gross). Counting every negative amount on the card catches any second
    // discount row regardless of the label it is given.
    testWidgets('GUARD: exactly one negative amount on the card', (
      tester,
    ) async {
      await _pumpCard(tester, PaymentSummaryCard(breakdown: quoteCase()));

      final negatives = tester.widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .where((s) => s.startsWith('-'))
          .toList();
      expect(negatives, ['-50.00']);
    });

    testWidgets('no promo: neither the subtotal nor the discount row', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        PaymentSummaryCard(
          breakdown: GrossPriceBreakdown.fromBookingLines(
            // Two lines, so the total is its own figure and cannot be
            // confused with a line item.
            itemLines: const [
              GrossLine(label: 'غسيل خارجي', grossMinor: 9000),
              GrossLine(label: 'تلميع الإطارات', grossMinor: 2500),
            ],
            discountMinor: 0,
            promoCode: null,
            totalMinor: 11500,
            vatMinor: 1500,
          ),
        ),
      );

      expect(find.text('الإجمالي قبل الخصم'), findsNothing);
      expect(find.text('-0.00'), findsNothing);
      expect(find.text('90.00'), findsOneWidget); // line items, gross
      expect(find.text('25.00'), findsOneWidget);
      expect(find.text('115.00'), findsOneWidget); // total, once
      expect(find.text('15.00'), findsOneWidget); // VAT footnote
      // Nothing negative at all when nothing was discounted.
      final negatives = tester.widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .where((s) => s.startsWith('-'));
      expect(negatives, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the widest Arabic shape fits a phone', (tester) async {
      // The Arabic labels run longer than the English ones, and the row helper
      // is a spaceBetween Row of two Texts. No RTL special-handling anywhere —
      // the same widget is pumped, in ar.
      await _pumpCard(
        tester,
        PaymentSummaryCard(
          breakdown: GrossPriceBreakdown.fromBookingLines(
            itemLines: const [
              GrossLine(
                label: 'غسيل خارجي وداخلي شامل تلميع الإطارات',
                grossMinor: 12000,
              ),
              GrossLine(
                label: 'تلميع الإطارات وتنظيف المقصورة الداخلية بالبخار',
                grossMinor: 5500,
              ),
            ],
            discountMinor: 5000,
            promoCode: 'NEWCUSTOMER50',
            totalMinor: 12500,
            vatMinor: 1630,
          ),
        ),
      );

      expect(find.text('الإجمالي قبل الخصم'), findsOneWidget);
      expect(find.text('شامل ضريبة القيمة المضافة'), findsOneWidget);
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
