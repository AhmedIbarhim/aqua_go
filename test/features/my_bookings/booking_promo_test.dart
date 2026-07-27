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

    test('a code that saved nothing reads as empty', () {
      // Naming a saving of 0.00 would read as a bug rather than as a fact.
      final booking = BookingResponseModel.fromJson(
        _bookingJson(promo: {'code': 'WELCOME20', 'discountMinor': 0}),
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
      expect(find.text('WELCOME20'), findsOneWidget);
      // original == total + discount, exactly: the backend subtracts the
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
      expect(find.text('WELCOME20'), findsOneWidget);
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
      expect(find.text('WELCOME20'), findsOneWidget);
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
      expect(find.text('WELCOME20'), findsOneWidget);
      expect(find.text('الإجمالي قبل الخصم'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    /// The defect this closes: the backend states the wash's PRE-discount price
    /// on the SERVICE row and carries the saving as its own negative row, so a
    /// card that renders the item rows and drops the discount shows a column
    /// adding up to more than the Subtotal printed directly beneath it.
    ///
    /// 80.00 service + 20.00 add-on − 17.39 discount == 82.61 subtotal. Every
    /// figure is the backend's own `netMinor`; nothing here is recomputed.
    testWidgets('the item rows still reconcile with the Subtotal beneath them', (
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

      expect(find.text('80.00 SAR'), findsOneWidget, reason: 'the wash, before the code');
      expect(find.text('20.00 SAR'), findsOneWidget, reason: 'the add-on');
      expect(
        find.text('-17.39 SAR'),
        findsOneWidget,
        reason: 'the saving, stated NET like every other row in this column',
      );
      expect(find.text('82.61 SAR'), findsOneWidget, reason: 'the subtotal they sum to');
      // The VAT-inclusive promo statement below is unchanged and separate.
      expect(find.text('-20.00 SAR'), findsOneWidget);
      expect(find.text('115.00 SAR'), findsOneWidget);
      expect(find.text('95.00 SAR'), findsOneWidget);
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
      expect(find.text('Promo discount (before VAT)'), findsNothing);
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
}
