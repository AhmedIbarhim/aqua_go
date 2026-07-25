import 'dart:convert';

import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/enums/payment_method_enum.dart';
import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:aqua_go/features/address/data/models/address_model.dart';
import 'package:aqua_go/features/booking/data/data_sources/bookings_remote_data_source.dart';
import 'package:aqua_go/features/booking/data/models/availability_response_model.dart';
import 'package:aqua_go/features/booking/data/models/payment_init_model.dart';
import 'package:aqua_go/features/booking/data/models/quote_model.dart';
import 'package:aqua_go/features/booking/data/repos/booking_repository.dart';
import 'package:aqua_go/features/booking/domain/strategies/booking_submit_strategy.dart';
import 'package:aqua_go/features/booking/presentation/controllers/booking_cubit.dart';
import 'package:aqua_go/features/booking/presentation/controllers/booking_state.dart';
import 'package:aqua_go/features/booking/presentation/views/booking_summary_view.dart';
import 'package:aqua_go/features/home/data/data_source/services_remote_data_source.dart';
import 'package:aqua_go/features/home/data/models/service_model.dart';
import 'package:aqua_go/features/home/data/repos/services_repository.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/features/my_cars/data/models/my_car_model.dart';
import 'package:aqua_go/features/my_cars/data/models/vehicle_make_model.dart';
import 'package:aqua_go/features/my_cars/data/models/vehicle_model_model.dart';
import 'package:aqua_go/core/config/controllers/language_controller/language_cubit.dart';
import 'package:aqua_go/features/subscriptions/data/data_sources/subscriptions_remote_data_source.dart';
import 'package:aqua_go/features/subscriptions/data/repos/subscriptions_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression cover for the price-lock re-quote on [BookingSummaryView].
///
/// The 15-minute quote TTL can expire while the customer sits on the summary
/// screen. Confirm then re-quotes before charging and aborts when the total
/// moved. [BookingCubit.fetchQuote] is stateless with respect to the promo —
/// it only forwards what the caller hands it — so that refresh MUST re-send the
/// promo code held in the view's state. Omitting it re-quotes at the
/// undiscounted price, which silently drops the discount AND makes the gross
/// comparison fail forever, so the booking can never be completed while a promo
/// is applied.
/// Gross totals the fake backend quotes with and without the promo. The
/// discounted one is what the customer sees before the TTL lapses.
const _grossWithoutPromoMinor = 11500;
const _grossWithPromoMinor = 9500;
const _promoDiscountMinor = _grossWithoutPromoMinor - _grossWithPromoMinor;

void main() {
  const promoCode = 'WELCOME15';

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await CacheClient.init();
    await EasyLocalization.ensureInitialized();
    // Read the real English bundle ONCE, outside the widget tests, so the
    // widget tree never waits on asset I/O (which does not settle under the
    // fake async clock a widget test runs on).
    _enTranslations =
        json.decode(await rootBundle.loadString('assets/translations/en.json'))
            as Map<String, dynamic>;
  });

  testWidgets('expired-quote refresh re-sends the applied promo code', (
    tester,
  ) async {
    final repo = _RecordingBookingRepo();
    final cubit = _buildCubit(repo);
    addTearDown(cubit.close);

    await _pumpSummary(tester, cubit);

    // Initial mount quote — no promo yet.
    expect(repo.quoteCalls, [null]);

    await _applyPromo(tester, promoCode);

    // The applied quote is the discounted one and it is already expired.
    expect(repo.quoteCalls, [null, promoCode]);
    expect(cubit.state.quote!.breakdown!.grossMinor, _grossWithPromoMinor);

    await _tapConfirm(tester);

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
    final repo = _RecordingBookingRepo();
    final cubit = _buildCubit(repo);
    addTearDown(cubit.close);

    await _pumpSummary(tester, cubit);
    expect(repo.quoteCalls, [null]);
    expect(cubit.state.quote!.breakdown!.grossMinor, _grossWithoutPromoMinor);

    await _tapConfirm(tester);

    expect(repo.quoteCalls, [null, null]);
    expect(repo.paymentInitCalls, 1);
  });
}

/// Pumps [BookingSummaryView] with the localization + theme + cubit scaffolding
/// the real app provides, and lets the post-frame initial quote settle.
Future<void> _pumpSummary(WidgetTester tester, BookingCubit cubit) async {
  // Generous surface: widget tests render with the fixed-width test font, which
  // is far wider than the shipped one, so a phone-sized canvas overflows rows
  // that are fine on a device. This test asserts behaviour, not layout.
  tester.view.physicalSize = const Size(1400, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      saveLocale: false,
      assetLoader: _InMemoryTranslations(_enTranslations),
      child: Builder(
        builder: (context) => MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          theme: ThemeData(extensions: const [darkAppColors]),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<LanguageCubit>(create: (_) => LanguageCubit()),
              BlocProvider<BookingCubit>.value(value: cubit),
            ],
            child: const BookingSummaryView(),
          ),
        ),
      ),
    ),
  );
  await _settle(tester);
}

/// The app's real English strings, read once in [setUpAll].
late final Map<String, dynamic> _enTranslations;

/// Serves the pre-read bundle synchronously — no asset I/O inside the tests.
class _InMemoryTranslations extends AssetLoader {
  const _InMemoryTranslations(this.data);

  final Map<String, dynamic> data;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) =>
      SynchronousFuture(data);
}

/// Pumps in small steps so every frame boundary between a request going out and
/// its reply arriving is actually drawn — the screen's loading overlay is
/// inserted from a post-frame callback, so a single coarse `pumpAndSettle`
/// would collapse show+hide into one frame gap and leave a dangling entry.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 10));
  }
  await tester.pumpAndSettle();
}

/// Drives the real promo UI: opens the dialog, types the code, applies it.
Future<void> _applyPromo(WidgetTester tester, String code) async {
  final openPromo = find.byIcon(Icons.discount_outlined);
  await tester.ensureVisible(openPromo);
  await tester.pumpAndSettle();
  await tester.tap(openPromo);
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField), code);
  await tester.tap(find.byType(ElevatedButton));
  await _settle(tester);
}

Future<void> _tapConfirm(WidgetTester tester) async {
  await tester.tap(find.byType(MaterialButton).last);
  await _settle(tester);
}

BookingCubit _buildCubit(_RecordingBookingRepo repo) {
  final apiClient = APIClient(Dio());
  final cubit = BookingCubit(
    bookingRepo: repo,
    subscriptionsRepo: SubscriptionsRepository(
      SubscriptionsRemoteDataSource(apiClient),
    ),
    servicesRepo: ServicesRepository(ServicesRemoteDataSource(apiClient)),
    submitStrategy: _UnusedSubmitStrategy(),
  );

  cubit.initBooking(
    _service,
    existingCar: _car,
    existingAddress: _address,
  );
  final date = DateTime.now().add(const Duration(days: 2));
  cubit.updateDateTime(date, null);
  cubit.updateDateTime(date, '10:00 AM');
  cubit.updatePaymentMethod(PaymentMethod.creditCard);
  return cubit;
}

final _service = ServiceModel(
  id: 'svc-1',
  rawName: const ServiceName(nameAr: 'غسيل خارجي', nameEn: 'Exterior Wash'),
);

final _address = AddressModel(
  id: 'addr-1',
  label: 'Home',
  details: 'Jeddah',
  lat: 21.4858,
  lng: 39.1925,
  zoneId: 'zone-1',
);

final _car = MyCarModel(
  id: 'car-1',
  makeId: 'make-1',
  modelId: 'model-1',
  color: '0xFF000000',
  plateNumber: 'ABC 1234',
  carMake: const VehicleMakeModel(
    id: 'make-1',
    vehicleMakeName: MakeName(nameAr: 'تويوتا', nameEn: 'Toyota'),
    active: true,
    version: 1,
  ),
  carModel: const VehicleModelModel(
    id: 'model-1',
    makeId: 'make-1',
    vehicleModelName: ModelName(nameAr: 'كامري', nameEn: 'Camry'),
    active: true,
    version: 1,
  ),
);

/// Spans at least one frame, the way a real HTTP round-trip does, so the
/// screen's loading overlay is inserted before it is torn down.
Future<void> _networkTick() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

/// Booking repository that records the promo code each quote call carried and
/// answers with an ALREADY-EXPIRED quote, so the summary screen always takes
/// the price-lock refresh branch on Confirm.
class _RecordingBookingRepo extends BookingRepository {
  _RecordingBookingRepo()
    : super(bookingsRemoteDataSource: BookingsRemoteDataSource(APIClient(Dio())));

  /// One entry per [getQuote] call, holding the promo code it was given.
  final List<String?> quoteCalls = [];
  int paymentInitCalls = 0;

  @override
  Future<Either<Failure, QuoteModel>> getQuote({
    required String packageId,
    required double lat,
    required double lng,
    List<Map<String, dynamic>>? addOns,
    String? promoCode,
    List<String> addOnIds = const [],
    int? carCount,
  }) async {
    quoteCalls.add(promoCode);
    await _networkTick();
    final grossMinor = promoCode == null
        ? _grossWithoutPromoMinor
        : _grossWithPromoMinor;
    final vatMinor = (grossMinor * 15 / 115).round();
    return right(
      QuoteModel.fromJson({
        'quoteId': 'quote-${quoteCalls.length}',
        'totalMinor': grossMinor,
        'vatMinor': vatMinor,
        'currency': 'SAR',
        // Already past the 15-minute TTL.
        'expiresAt': DateTime.now()
            .toUtc()
            .subtract(const Duration(minutes: 1))
            .toIso8601String(),
        'promoCode': ?promoCode,
        'promoDiscountMinor': promoCode == null ? 0 : _promoDiscountMinor,
        'breakdown': {
          'grossMinor': grossMinor,
          'netMinor': grossMinor - vatMinor,
          'vatMinor': vatMinor,
          'currency': 'SAR',
        },
      }),
    );
  }

  @override
  Future<Either<Failure, PaymentInitModel>> bookingPaymentInit({
    required String quoteId,
    required String scheduledAt,
    required List<Map<String, dynamic>> vehicles,
    required String attemptNonce,
  }) async {
    paymentInitCalls++;
    await _networkTick();
    // Stops the flow before the Moyasar SDK screen — the view treats a null
    // init as "abort quietly", which is all this test needs.
    return left(ServerFailure('payment init not exercised in this test'));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkZoneAvailability(
    double lat,
    double lng,
  ) async => right({'zoneId': 'zone-1', 'covered': true});

  @override
  Future<Either<Failure, AvailabilityResponse>> getAvailability({
    required String zoneId,
    required String date,
    required String packageId,
  }) async => right(AvailabilityResponse.fromJson(const {'slots': []}));
}

/// The summary screen never bare-submits in the paid service flow, so the
/// strategy is only here to satisfy the cubit's constructor.
class _UnusedSubmitStrategy implements BookingSubmitStrategy {
  @override
  Future<Either<Failure, BookingResponseModel>> submit({
    required BookingRepository repo,
    required BookingState state,
    String? moyasarPaymentId,
  }) async => left(ServerFailure('submit not exercised in this test'));
}
