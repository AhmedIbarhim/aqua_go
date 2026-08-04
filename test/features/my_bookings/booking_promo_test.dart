import 'package:aqua_go/core/config/controllers/language_controller/language_cubit.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/features/my_bookings/presentation/widgets/booking_details_summary_card.dart';
import 'package:aqua_go/generated/codegen_loader.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The wire shape of a discounted booking. `discountMinor` is ALREADY netted off
/// `totalAmountMinor`, so 9500 charged + 2000 saved describes an 11500 original.
Map<String, dynamic> _bookingJson({
  Map<String, dynamic>? promo,
  int totalAmountMinor = 9500,
  bool? tipPaid,
  int? tipAmountMinor,
}) => {
  'id': 'booking-1',
  'referenceNumber': 'BK-000123',
  'type': 'SCHEDULED',
  'status': 'PENDING',
  'scheduledAt': '2026-08-02T10:00:00',
  'totalAmountMinor': totalAmountMinor,
  'currency': 'SAR',
  'isSubscription': false,
  'promo': ?promo,
  'tipPaid': ?tipPaid,
  'tipAmountMinor': ?tipAmountMinor,
};

/// The per-line breakdown of a discounted booking, exactly as the server now
/// rebuilds it: the SERVICE row states the PRE-discount wash price and a
/// negative DISCOUNT row carries the saving, so the rows still sum to the
/// charged total (9200 + 2300 − 2000 == 9500) and to the net subtotal
/// (8000 + 2000 − 1739 == 8261). The fixture used to encode the pre-fix shape,
/// which is why no test saw the card stop reconciling.
const List<Map<String, dynamic>> _discountedLines = [
  {
    'kind': 'SERVICE',
    'refId': 'pkg-1',
    'grossMinor': 9200,
    'netMinor': 8000,
    'vatMinor': 1200,
  },
  {
    'kind': 'ADDON',
    'refId': 'addon-1',
    'grossMinor': 2300,
    'netMinor': 2000,
    'vatMinor': 300,
  },
  {
    'kind': 'DISCOUNT',
    'refId': null,
    'grossMinor': -2000,
    'netMinor': -1739,
    'vatMinor': -261,
  },
];

Future<void> _pumpCard(
  WidgetTester tester,
  BookingResponseModel booking, {
  Locale locale = const Locale('en'),
}) async {
  // A real phone width, not the 800x600 test default — the summary rows are
  // unbounded spaceBetween Rows, and 800pt hides every overflow they can have.
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await CacheClient.setString(kLanguage, locale.languageCode);
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: locale,
      assetLoader: const CodegenLoader(),
      child: BlocProvider(
        create: (_) => LanguageCubit(),
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
                child: BookingDetailsSummaryCard(booking: booking),
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

void main() {
  group('BookingPromo.fromJson', () {
    test('parses the full record', () {
      final booking = BookingResponseModel.fromJson(
        _bookingJson(
          promo: {
            'code': 'WELCOME20',
            'discountMinor': 2000,
            'offerId': '018f-offer',
            'redeemedAt': '2026-07-26T14:30:00',
          },
        ),
      );
      final promo = booking.promo!;
      expect(promo.code, 'WELCOME20');
      expect(promo.discountMinor, 2000);
      expect(promo.discount, 20.0);
      expect(promo.offerId, '018f-offer');
      // Bare Riyadh wall clock -> the Riyadh frame, on any device.
      expect(promo.redeemedAt, DateTime.utc(2026, 7, 26, 14, 30));
      expect(promo.releasedAt, isNull);
      expect(promo.isReleased, isFalse);
      expect(promo.isEmpty, isFalse);
      expect(promo.hasDiscount, isTrue);
    });

    test('a released redemption carries its release instant', () {
      final booking = BookingResponseModel.fromJson(
        _bookingJson(
          promo: {
            'code': 'WELCOME20',
            'discountMinor': 2000,
            'redeemedAt': '2026-07-26T14:30:00',
            'releasedAt': '2026-07-27T09:00:00',
          },
        ),
      );
      expect(booking.promo!.isReleased, isTrue);
      expect(booking.promo!.releasedAt, DateTime.utc(2026, 7, 27, 9));
    });

    test('a booking with no promo parses to null, not to an empty promo', () {
      expect(BookingResponseModel.fromJson(_bookingJson()).promo, isNull);
    });

    test('a malformed promo payload degrades to null instead of throwing', () {
      // Read-reconstruction path: stored data must keep reading.
      final json = _bookingJson()..['promo'] = 'WELCOME20';
      expect(BookingResponseModel.fromJson(json).promo, isNull);
    });

    test('a code that saved nothing is still a redemption, not an absence', () {
      // It was redeemed against this booking, so it is NOT empty — only the
      // saving is missing. Naming a saving of 0.00 would read as a bug; erasing
      // the code entirely erases a fact the review screen states.
      final booking = BookingResponseModel.fromJson(
        _bookingJson(promo: {'code': 'WELCOME20', 'discountMinor': 0}),
      );
      expect(booking.promo!.isEmpty, isFalse);
      expect(booking.promo!.hasDiscount, isFalse);
    });

    test('a promo payload with no code at all reads as empty', () {
      final booking = BookingResponseModel.fromJson(
        _bookingJson(promo: {'discountMinor': 0}),
      );
      expect(booking.promo!.isEmpty, isTrue);
    });

    test('the two other stale BookingResponse fields parse', () {
      final json = _bookingJson()
        ..['cantFindClientNotes'] = 'No answer at the gate'
        ..['addonPaymentIntentId'] = 'pi-addon-1';
      final booking = BookingResponseModel.fromJson(json);
      expect(booking.cantFindClientNotes, 'No answer at the gate');
      expect(booking.addonPaymentIntentId, 'pi-addon-1');
    });
  });

  group('BookingDetailsSummaryCard — UCC16 discount on the booking detail', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await CacheClient.init();
      await EasyLocalization.ensureInitialized();
    });

    testWidgets('states the code, the original total and what it saved', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        BookingResponseModel.fromJson(
          _bookingJson(
            promo: {
              'code': 'WELCOME20',
              'discountMinor': 2000,
              'redeemedAt': '2026-07-26T14:30:00',
            },
          ),
        ),
      );
      // The code is folded INTO the discount row — there is no separate
      // "Promo Code" row to state it twice.
      expect(find.text('WELCOME20 discount'), findsOneWidget);
      expect(find.text('Promo Code'), findsNothing);
      // subtotal == total + discount, exactly: the backend subtracts the
      // discount from the VAT-inclusive gross to reach the charged total.
      expect(find.text('115.00 SAR'), findsOneWidget);
      expect(find.text('-20.00 SAR'), findsOneWidget);
      expect(find.text('95.00 SAR'), findsOneWidget);
      expect(find.text('Code returned after cancellation'), findsNothing);
    });

    testWidgets('a released redemption keeps the rows and says so', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        BookingResponseModel.fromJson(
          _bookingJson(
            promo: {
              'code': 'WELCOME20',
              'discountMinor': 2000,
              'redeemedAt': '2026-07-26T14:30:00',
              'releasedAt': '2026-07-27T09:00:00',
            },
          ),
        ),
      );
      expect(find.text('WELCOME20 discount'), findsOneWidget);
      expect(find.text('-20.00 SAR'), findsOneWidget);
      expect(find.text('Code returned after cancellation'), findsOneWidget);
    });

    testWidgets('the Arabic rows fit — the labels are the long ones', (
      tester,
    ) async {
      // `_buildSummaryRow` is an unbounded spaceBetween Row, and the Arabic
      // labels are longer than the English ones ("الإجمالي قبل الخصم"). No RTL
      // special-handling anywhere — the same widget is pumped, in ar.
      await _pumpCard(
        tester,
        BookingResponseModel.fromJson(
          _bookingJson(
            promo: {
              'code': 'WELCOME20',
              'discountMinor': 2000,
              'redeemedAt': '2026-07-26T14:30:00',
              'releasedAt': '2026-07-27T09:00:00',
            },
          ),
        ),
        locale: const Locale('ar'),
      );
      expect(find.text('خصم WELCOME20'), findsOneWidget);
      expect(find.text('الإجمالي قبل الخصم'), findsOneWidget);
      expect(find.text('تمت إعادة الكود بعد الإلغاء'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the full card — add-ons, totals AND promo — fits in Arabic', (
      tester,
    ) async {
      // The widest shape the card takes: the Subtotal/VAT block draws too, and a
      // long add-on name is what used to push a row past the card edge.
      final json = _bookingJson(
        promo: {'code': 'WELCOME20', 'discountMinor': 2000},
      )
        ..['addOns'] = [
          {
            'addonId': 'addon-1',
            'nameAr': 'تلميع الإطارات وتنظيف المقصورة الداخلية بالبخار',
            'nameEn': 'Tyre polish and interior steam clean',
            'charged': 2300,
          },
        ]
        ..['lines'] = _discountedLines
        ..['breakdown'] = {
          'grossMinor': 9500,
          'netMinor': 8261,
          'vatMinor': 1239,
          'currency': 'SAR',
        };
      await _pumpCard(
        tester,
        BookingResponseModel.fromJson(json),
        locale: const Locale('ar'),
      );
      expect(find.text('خصم WELCOME20'), findsOneWidget);
      expect(find.text('الإجمالي قبل الخصم'), findsOneWidget);
      expect(find.text('شامل ضريبة القيمة المضافة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    /// Every visible figure is VAT-INCLUSIVE, and the item rows sum EXACTLY to
    /// the "before discount" subtotal printed beneath them:
    /// 92.00 service + 23.00 add-on == 115.00, − 20.00 == the 95.00 charged.
    /// Each is the backend's own `grossMinor`; nothing here is recomputed.
    ///
    /// This also guards the defect it replaced: the same discount stated twice
    /// in two bases (−17.39 net and −20.00 gross), against two competing
    /// subtotals (82.61 net and 115.00 gross), in one column.
    testWidgets('the item rows reconcile with the subtotal, all gross', (
      tester,
    ) async {
      final json = _bookingJson(
        promo: {'code': 'WELCOME20', 'discountMinor': 2000},
      )
        ..['addOns'] = [
          {
            'addonId': 'addon-1',
            'nameAr': 'تلميع الإطارات',
            'nameEn': 'Tyre polish',
            'charged': 2300,
          },
        ]
        ..['lines'] = _discountedLines
        ..['breakdown'] = {
          'grossMinor': 9500,
          'netMinor': 8261,
          'vatMinor': 1239,
          'currency': 'SAR',
        };
      await _pumpCard(tester, BookingResponseModel.fromJson(json));

      expect(find.text('92.00 SAR'), findsOneWidget, reason: 'the wash, gross, before the code');
      expect(find.text('23.00 SAR'), findsOneWidget, reason: 'the add-on, gross');
      expect(find.text('115.00 SAR'), findsOneWidget, reason: 'the subtotal they sum to');
      expect(
        find.text('-20.00 SAR'),
        findsOneWidget,
        reason: 'the saving, at its FULL value, stated exactly once',
      );
      expect(find.text('95.00 SAR'), findsOneWidget, reason: 'the charged total');
      expect(find.text('12.39 SAR'), findsOneWidget, reason: 'VAT, disclosed under the total');

      // GUARD — no net figure, and no second discount row. Red-proof: revert
      // the item rows to `line.net` in BookingDetailsSummaryCard._breakdown and
      // 80.00 / 20.00 render where 92.00 / 23.00 belong.
      for (final net in const [
        '80.00 SAR', // service net
        '20.00 SAR', // add-on net
        '82.61 SAR', // net subtotal — the second, competing base
        '-17.39 SAR', // the discount restated pre-VAT
      ]) {
        expect(
          find.text(net),
          findsNothing,
          reason: '$net is a net figure and must not be shown',
        );
      }
      final negatives = tester.widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .where((s) => s.startsWith('-'))
          .toList();
      expect(negatives, ['-20.00 SAR'], reason: 'exactly one discount row');
      expect(tester.takeException(), isNull);
    });

    testWidgets('a booking with no code shows no discount row', (tester) async {
      final json = _bookingJson()
        ..['addOns'] = [
          {
            'addonId': 'addon-1',
            'nameAr': 'تلميع الإطارات',
            'nameEn': 'Tyre polish',
            'charged': 2300,
          },
        ]
        ..['lines'] = [
          {
            'kind': 'SERVICE',
            'refId': 'pkg-1',
            'grossMinor': 7200,
            'netMinor': 6261,
            'vatMinor': 939,
          },
          {
            'kind': 'ADDON',
            'refId': 'addon-1',
            'grossMinor': 2300,
            'netMinor': 2000,
            'vatMinor': 300,
          },
        ]
        ..['breakdown'] = {
          'grossMinor': 9500,
          'netMinor': 8261,
          'vatMinor': 1239,
          'currency': 'SAR',
        };
      await _pumpCard(tester, BookingResponseModel.fromJson(json));
      // No code, so neither the discount row nor the "before discount"
      // subtotal it explains: the lines run straight into the total.
      expect(find.text('Original Total'), findsNothing);
      expect(find.text('72.00 SAR'), findsOneWidget, reason: 'the wash, gross');
      expect(find.text('23.00 SAR'), findsOneWidget, reason: 'the add-on, gross');
      expect(find.text('95.00 SAR'), findsOneWidget, reason: 'the total');
      final negatives = tester.widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .where((s) => s.startsWith('-'));
      expect(negatives, isEmpty);
    });

    testWidgets('a code that saved nothing states no discount and no subtotal', (
      tester,
    ) async {
      // A discount row worth 0.00, and a "before discount" total equal to the
      // total, both read as bugs. The code is surfaced only where it has a
      // value to state, so with no saving there is nothing to show.
      await _pumpCard(
        tester,
        BookingResponseModel.fromJson(
          _bookingJson(promo: {'code': 'WELCOME20', 'discountMinor': 0}),
        ),
      );
      expect(find.text('Original Total'), findsNothing);
      expect(find.text('WELCOME20 discount'), findsNothing);
      expect(find.text('-0.00 SAR'), findsNothing);
      expect(find.text('95.00 SAR'), findsOneWidget);
    });

    testWidgets('a booking with no promo renders no promo rows', (
      tester,
    ) async {
      await _pumpCard(tester, BookingResponseModel.fromJson(_bookingJson()));
      expect(find.text('Promo Code'), findsNothing);
      expect(find.text('Original Total'), findsNothing);
      expect(find.text('95.00 SAR'), findsOneWidget);
    });
  });

  group(
    'BookingDetailsSummaryCard — points on the taxable base, one payable row',
    () {
      setUp(() async {
        TestWidgetsFlutterBinding.ensureInitialized();
        SharedPreferences.setMockInitialValues({});
        await CacheClient.init();
        await EasyLocalization.ensureInitialized();
      });

      /// Pins the exact scenario reported: subtotal 175.00, promo 50.00 off,
      /// points worth 24.00 redeemed, total 101.00. Points are a discount on
      /// the taxable base now, exactly like the promo, so `totalAmountMinor`
      /// (10100) is ALREADY net of both — there is no second "Card Charged"
      /// row stating 101.00 again, and no row anywhere states 125.00 (the old
      /// subtotal-minus-promo-only figure) or 77.00 (the old
      /// total-minus-points tender figure).
      testWidgets(
        'renders subtotal, promo, points, and exactly ONE payable Total row',
        (tester) async {
          final json = _bookingJson(
            promo: {'code': 'NEWCUST50', 'discountMinor': 5000},
            totalAmountMinor: 10100,
          )
            ..['promoPoints'] = {
              'promoCode': 'NEWCUST50',
              'promoDiscountMinor': 5000,
              'pointsApplied': 2400,
              'pointsDiscountMinor': 2400,
              // Equals totalAmountMinor exactly — wire back-compat only, and
              // the card must not render this as a second figure.
              'cardChargeMinor': 10100,
              'currency': 'SAR',
            }
            ..['lines'] = const [
              {
                'kind': 'SERVICE',
                'refId': 'pkg-1',
                'grossMinor': 17500,
                'netMinor': 15217,
                'vatMinor': 2283,
              },
              {
                'kind': 'DISCOUNT',
                'refId': null,
                'grossMinor': -5000,
                'netMinor': -4348,
                'vatMinor': -652,
              },
            ]
            ..['breakdown'] = {
              'grossMinor': 10100,
              'netMinor': 8783,
              'vatMinor': 1317,
              'currency': 'SAR',
            };
          await _pumpCard(tester, BookingResponseModel.fromJson(json));

          // Renders twice: once as the single SERVICE item row (there is
          // only one line, so it equals the subtotal) and once as the
          // "before discount" subtotal row itself.
          expect(find.text('175.00 SAR'), findsNWidgets(2), reason: 'the service line and the subtotal it equals');
          expect(find.text('-50.00 SAR'), findsOneWidget, reason: 'the promo discount');
          expect(find.text('-24.00 SAR'), findsOneWidget, reason: 'the points discount');
          expect(find.text('101.00 SAR'), findsOneWidget, reason: 'the ONE payable Total row');
          expect(find.text('13.17 SAR'), findsOneWidget, reason: 'VAT, disclosed under the total');

          // No duplicate payable row, and no stale intermediate figure.
          expect(find.text('Card Charged'), findsNothing);
          expect(find.text('125.00 SAR'), findsNothing, reason: 'subtotal - promo only, no longer a figure on screen');
          expect(find.text('77.00 SAR'), findsNothing, reason: 'the old total-minus-points tender figure');
          expect(tester.takeException(), isNull);
        },
      );
    },
  );

  group('BookingDetailsSummaryCard — tip row', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await CacheClient.init();
      await EasyLocalization.ensureInitialized();
    });

    testWidgets('a paid tip renders its own row, in a separate card', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        BookingResponseModel.fromJson(
          _bookingJson(tipPaid: true, tipAmountMinor: 5000),
        ),
      );
      // The wash total (95.00) and the tip (50.00) are two distinct figures —
      // neither is folded into the other.
      expect(find.text('95.00 SAR'), findsOneWidget);
      expect(find.text('Tip (paid separately)'), findsOneWidget);
      expect(find.text('50.00 SAR'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the tip row renders in Arabic too', (tester) async {
      await _pumpCard(
        tester,
        BookingResponseModel.fromJson(
          _bookingJson(tipPaid: true, tipAmountMinor: 5000),
        ),
        locale: const Locale('ar'),
      );
      expect(find.text('الإكرامية (تدفع بشكل منفصل)'), findsOneWidget);
      expect(find.text('50.00 SAR'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no tip row when tipPaid is false', (tester) async {
      await _pumpCard(
        tester,
        BookingResponseModel.fromJson(
          _bookingJson(tipPaid: false, tipAmountMinor: 5000),
        ),
      );
      expect(find.text('Tip (paid separately)'), findsNothing);
      expect(find.text('50.00 SAR'), findsNothing);
    });

    testWidgets('no tip row when tipPaid and tipAmountMinor are both absent', (
      tester,
    ) async {
      await _pumpCard(tester, BookingResponseModel.fromJson(_bookingJson()));
      expect(find.text('Tip (paid separately)'), findsNothing);
    });

    testWidgets('no tip row for a zero tip amount, even if tipPaid is true', (
      tester,
    ) async {
      // Defensive: a 0-value tip should never render an empty row.
      await _pumpCard(
        tester,
        BookingResponseModel.fromJson(
          _bookingJson(tipPaid: true, tipAmountMinor: 0),
        ),
      );
      expect(find.text('Tip (paid separately)'), findsNothing);
    });
  });
}
