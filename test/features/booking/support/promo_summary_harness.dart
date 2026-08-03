import 'dart:convert';

import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/utils/saudi_wire_format.dart';
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
import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/features/booking/presentation/views/booking_details_view.dart';
import 'package:aqua_go/features/home/data/models/add_on_model.dart';
import 'package:aqua_go/features/my_cars/data/data_sources/cars_remote_data_source.dart';
import 'package:aqua_go/features/my_cars/data/repos/cars_repository.dart';
import 'package:aqua_go/features/my_cars/presentation/controllers/my_cars_cubit.dart';
import 'package:aqua_go/features/home/data/data_source/services_remote_data_source.dart';
import 'package:aqua_go/features/home/data/models/service_model.dart';
import 'package:aqua_go/features/home/data/repos/services_repository.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/features/my_cars/data/models/my_car_model.dart';
import 'package:aqua_go/features/my_cars/data/models/vehicle_make_model.dart';
import 'package:aqua_go/features/my_cars/data/models/vehicle_model_model.dart';
import 'package:aqua_go/core/config/controllers/language_controller/language_cubit.dart';
import 'package:aqua_go/core/config/controllers/theme_controller/theme_cubit.dart';
import 'package:aqua_go/features/subscriptions/data/data_sources/subscriptions_remote_data_source.dart';
import 'package:aqua_go/features/subscriptions/data/repos/subscriptions_repository.dart';
import 'package:aqua_go/features/wallet/data/data_sources/wallet_remote_data_source.dart';
import 'package:aqua_go/features/wallet/data/models/loyalty_balance_model.dart';
import 'package:aqua_go/features/wallet/data/repos/wallet_repository.dart';
// dartz exports a `State` monad that collides with Flutter's widget `State`,
// which this file's docs refer to. Nothing here uses the monad.
import 'package:dartz/dartz.dart' hide State;
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shared scaffolding for the promo tests that drive the REAL
/// [BookingSummaryView] — the app's localization, theme and cubit wiring, a
/// recording booking repository, and the gestures that work the promo UI.
///
/// Every promo behaviour under test (survives navigation, drops a code that has
/// gone invalid, renders the saved amount, states the refund) is a property of
/// that screen wired to that cubit, so the tests exercise both rather than a
/// stand-in.

/// Gross totals the fake backend quotes with and without a promo.
const grossWithoutPromoMinor = 11500;
const grossWithPromoMinor = 9500;
const promoDiscountMinor = grossWithoutPromoMinor - grossWithPromoMinor;

/// The code the fake backend resolves an offer-driven quote to. An offer-driven
/// request carries only the offer id; the server looks up the offer's LINKED
/// promo code and echoes it on the quote, which is what the applied-code chip
/// and the create call read.
const offerResolvedPromoCode = 'OFFERCODE';

/// The app's real English strings, read once by [loadTranslations].
Map<String, dynamic>? _enTranslations;

/// Reads the shipped English bundle ONCE, outside the widget tests, so the
/// widget tree never waits on asset I/O (which does not settle under the fake
/// async clock a widget test runs on).
Future<void> loadTranslations() async {
  _enTranslations ??=
      json.decode(await rootBundle.loadString('assets/translations/en.json'))
          as Map<String, dynamic>;
}

/// Serves the pre-read bundle synchronously — no asset I/O inside the tests.
class _InMemoryTranslations extends AssetLoader {
  const _InMemoryTranslations(this.data);

  final Map<String, dynamic> data;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) =>
      SynchronousFuture(data);
}

/// Pumps [BookingSummaryView] with the localization + theme + cubit scaffolding
/// the real app provides, and lets the post-frame initial quote settle.
Future<void> pumpSummary(WidgetTester tester, BookingCubit cubit) async {
  // Generous surface: widget tests render with the fixed-width test font, which
  // is far wider than the shipped one, so a phone-sized canvas overflows rows
  // that are fine on a device. These tests assert behaviour, not layout.
  tester.view.physicalSize = const Size(1400, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  _ensureWalletRepositoryRegistered();
  await tester.pumpWidget(_summaryApp(cubit));
  await settle(tester);
}

/// Tears the summary out of the tree, destroying its [State] exactly as popping
/// the route does, then mounts it again on the SAME cubit.
Future<void> remountSummary(WidgetTester tester, BookingCubit cubit) async {
  _ensureWalletRepositoryRegistered();
  await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
  await tester.pump();
  await tester.pumpWidget(_summaryApp(cubit));
  await settle(tester);
}

/// [BookingSummaryView] reads its loyalty balance from the service locator on
/// a service-flow booking (`_fetchLoyaltyBalance`). Registers a fake that
/// answers with an empty balance instead of reaching the network, guarded the
/// same way [pumpDetails] guards `MyCarsCubit` — a test that mounts the
/// summary more than once (remount, details → summary) must not double-teardown
/// a type an earlier call already unregistered.
void _ensureWalletRepositoryRegistered() {
  if (locator.isRegistered<WalletRepository>()) {
    return;
  }
  locator.registerLazySingleton<WalletRepository>(() => _NoWalletRepository());
  addTearDown(() async {
    if (locator.isRegistered<WalletRepository>()) {
      await locator.unregister<WalletRepository>();
    }
  });
}

/// Pumps [BookingDetailsView] — the screen the customer pops BACK to from the
/// summary — with the same scaffolding. Its `MyCarsCubit` comes from the
/// service locator, so a fake is registered here rather than reaching the
/// network.
Future<void> pumpDetails(WidgetTester tester, BookingCubit cubit) async {
  tester.view.physicalSize = const Size(1400, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  if (locator.isRegistered<MyCarsCubit>()) {
    await locator.unregister<MyCarsCubit>();
  }
  locator.registerFactory<MyCarsCubit>(
    () => MyCarsCubit(carsRepository: _NoCarsRepository()),
  );
  // Guarded, because a test that walks details → summary → details calls this
  // twice and so queues two teardowns; the second would unregister a type the
  // first already took out.
  addTearDown(() async {
    if (locator.isRegistered<MyCarsCubit>()) {
      await locator.unregister<MyCarsCubit>();
    }
  });

  // Blank frame first, so a summary already on screen is torn down exactly as
  // popping its route does rather than being swapped underneath its overlay.
  await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
  await tester.pump();
  await tester.pumpWidget(_localizedApp(cubit, const BookingDetailsView()));
  await settle(tester);
}

/// Answers the car list with nothing, so the details screen renders its
/// "add a car" state instead of waiting on HTTP.
class _NoCarsRepository extends CarsRepository {
  _NoCarsRepository() : super(CarsRemoteDataSource(APIClient(Dio())));

  @override
  Future<Either<Failure, List<MyCarModel>>> fetchCars() async => right(const []);
}

/// Answers the loyalty balance with a zeroed-out fake, so the summary screen's
/// post-frame `_fetchLoyaltyBalance` settles instead of reaching the network.
class _NoWalletRepository extends WalletRepository {
  _NoWalletRepository() : super(WalletRemoteDataSource(APIClient(Dio())));

  @override
  Future<Either<Failure, LoyaltyBalanceModel>> getWalletBalance() async =>
      right(
        LoyaltyBalanceModel(
          points: 0,
          estimatedValueMinor: 0,
          redemptionRateMinorPerPoint: 1,
          earnMinorPerPoint: 0,
          maxCoveragePct: 100,
          recentEntries: const [],
        ),
      );
}

Widget _summaryApp(BookingCubit cubit) =>
    _localizedApp(cubit, const BookingSummaryView());

Widget _localizedApp(BookingCubit cubit, Widget home) {
  return EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('ar')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    saveLocale: false,
    assetLoader: _InMemoryTranslations(_enTranslations!),
    child: Builder(
      builder: (context) => MaterialApp(
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        theme: ThemeData(extensions: const [darkAppColors]),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<LanguageCubit>(create: (_) => LanguageCubit()),
            // The details screen's shimmer placeholders read the theme cubit.
            BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
            BlocProvider<BookingCubit>.value(value: cubit),
          ],
          child: home,
        ),
      ),
    ),
  );
}

/// Pumps in small steps so every frame boundary between a request going out and
/// its reply arriving is actually drawn — the screen's loading overlay is
/// inserted from a post-frame callback, so a single coarse `pumpAndSettle`
/// would collapse show+hide into one frame gap and leave a dangling entry.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 10));
  }
  await tester.pumpAndSettle();
}

/// Opens the "add a promo code" dialog from the summary's promo section.
Future<void> openPromoDialog(WidgetTester tester) async {
  final openPromo = find.byIcon(Icons.discount_outlined);
  await tester.ensureVisible(openPromo);
  await tester.pumpAndSettle();
  await tester.tap(openPromo);
  await tester.pumpAndSettle();
}

/// The dialog's Apply action — the house `CustomButton`, which is a
/// `MaterialButton` underneath.
final Finder promoApplyButton = find.descendant(
  of: find.byKey(const ValueKey('promo-apply')),
  matching: find.byType(MaterialButton),
);

/// Whether the dialog's Apply action is currently tappable. It is disabled
/// until the typed code has the shape the server accepts. Asserted on the
/// button's OWN `enabled`, i.e. whether `onPressed` survived — not on the flag
/// the caller passed in.
bool applyButtonEnabled(WidgetTester tester) =>
    tester.widget<MaterialButton>(promoApplyButton).enabled;

/// Drives the real promo UI: opens the dialog, types the code, applies it.
Future<void> applyPromo(WidgetTester tester, String code) async {
  await openPromoDialog(tester);
  await tester.enterText(find.byType(TextField), code);
  await tester.pumpAndSettle();
  await tester.tap(promoApplyButton);
  await settle(tester);
}

Future<void> tapConfirm(WidgetTester tester) async {
  await tester.tap(find.byType(MaterialButton).last);
  await settle(tester);
}

BookingCubit buildCubit(
  BookingRepository repo, {
  BookingSubmitStrategy? submitStrategy,
  ServiceModel? withService,
  /// The two display figures a SERVICE offer card hands into the flow. Left
  /// null, the cubit is an ordinary booking that never came through an offer —
  /// which is what every pre-existing caller of this helper is.
  int? offerListPriceMinor,
  int? offerTargetPriceMinor,
  /// The offer's own name, as the offer detail screen hands it in. Left null,
  /// the re-apply card falls back to its generic copy.
  String? offerTitleAr,
  String? offerTitleEn,
}) {
  final apiClient = APIClient(Dio());
  final cubit = BookingCubit(
    bookingRepo: repo,
    subscriptionsRepo: SubscriptionsRepository(
      SubscriptionsRemoteDataSource(apiClient),
    ),
    servicesRepo: ServicesRepository(ServicesRemoteDataSource(apiClient)),
    submitStrategy: submitStrategy ?? UnusedSubmitStrategy(),
  );

  cubit.initBooking(
    withService ?? service,
    existingCar: car,
    existingAddress: address,
    offerListPriceMinor: offerListPriceMinor,
    offerTargetPriceMinor: offerTargetPriceMinor,
    offerTitleAr: offerTitleAr,
    offerTitleEn: offerTitleEn,
  );
  final date = DateTime.now().add(const Duration(days: 2));
  final slotStart = DateTime(date.year, date.month, date.day, 10, 0);
  cubit.updateDateTime(date, null);
  cubit.updateDateTime(date, slotStart);
  cubit.updatePaymentMethod(PaymentMethod.creditCard);
  return cubit;
}

final service = ServiceModel(
  id: 'svc-1',
  rawName: const ServiceName(nameAr: 'غسيل خارجي', nameEn: 'Exterior Wash'),
);

/// The same service with one toggleable add-on, for the details screen — whose
/// add-on grid only renders when the selected service has add-ons.
final serviceWithAddOn = ServiceModel(
  id: 'svc-1',
  rawName: const ServiceName(nameAr: 'غسيل خارجي', nameEn: 'Exterior Wash'),
  addons: [
    AddOnModel(
      id: 'addon-1',
      nameAr: 'تلميع الإطارات',
      nameEn: 'Tyre Shine',
      priceMinor: 1500,
      currency: 'SAR',
    ),
  ],
);

final address = AddressModel(
  id: 'addr-1',
  label: 'Home',
  details: 'Jeddah',
  lat: 21.4858,
  lng: 39.1925,
  zoneId: 'zone-1',
);

final car = MyCarModel(
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
Future<void> networkTick() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

/// Builds the quote payload the fake backend answers with: totals already NET
/// of the promo, exactly as `PriceQuoteServiceImpl` returns them.
QuoteModel quotePayload({
  required String? promoCode,
  required String quoteId,
  bool expired = true,
  int addOnGrossMinor = 0,
}) {
  final grossMinor =
      (promoCode == null ? grossWithoutPromoMinor : grossWithPromoMinor) +
          addOnGrossMinor;
  final vatMinor = (grossMinor * 15 / 115).round();
  // VAT contained within the add-on's own gross, exactly as the server states
  // it on the ADDON row. The DISCOUNT row's VAT stays the residual below.
  final addOnVatMinor = (addOnGrossMinor * 15 / 115).round();
  // Riyadh frame, serialised BARE — the only shape the backend emits. A `Z`
  // here would hide the device-local parse the model is guarded against.
  final expiresAt = expired
      ? saudiNow().subtract(const Duration(minutes: 1))
      : saudiNow().add(const Duration(minutes: 15));
  return QuoteModel.fromJson({
    'quoteId': quoteId,
    'totalMinor': grossMinor,
    'vatMinor': vatMinor,
    'currency': 'SAR',
    'expiresAt': toWireDateTime(expiresAt),
    // The applied promo now travels in its OWN section, not as a top-level
    // field: `QuoteModel.promoCode` is a getter over `promo?.code`, so a fixture
    // that kept the flat key would read back as "no promo applied" and every
    // offer/promo assertion downstream would quietly test the wrong branch.
    if (promoCode != null)
      'promo': {
        'code': promoCode,
        'discountType': 'FIXED_AMOUNT',
        'percent': 0,
        'fixedAmountMinor': promoDiscountMinor,
        'discountMinor': promoDiscountMinor,
      },
    'breakdown': {
      'grossMinor': grossMinor,
      'netMinor': grossMinor - vatMinor,
      'vatMinor': vatMinor,
      'currency': 'SAR',
      'totalMinor': grossMinor,
      'promoDiscountMinor': promoCode == null ? 0 : promoDiscountMinor,
      'amountDueMinor': grossMinor,
    },
    // The wire's three-kind shape, mirrored EXACTLY as
    // `PriceQuoteServiceImpl.buildLines` emits it: the SERVICE row states the
    // PRE-discount wash price and a negative DISCOUNT row carries the saving,
    // so Σ gross == totalMinor and Σ vat == vatMinor. A fixture that netted the
    // discount into the service row (the shape the quote used to send) would
    // put the client's reconciliation one discount out and quietly pass.
    'lines': [
      {
        'kind': 'SERVICE',
        'refId': 'svc-1',
        'grossMinor': grossWithoutPromoMinor,
        'netMinor': grossWithoutPromoMinor - serviceVatMinor,
        'vatMinor': serviceVatMinor,
      },
      if (addOnGrossMinor > 0)
        {
          'kind': 'ADDON',
          'refId': 'addon-1',
          'grossMinor': addOnGrossMinor,
          'netMinor': addOnGrossMinor - addOnVatMinor,
          'vatMinor': addOnVatMinor,
        },
      // The DISCOUNT row's VAT is a RESIDUAL, exactly as the server derives it:
      // whatever makes the rows sum to the charged VAT.
      if (promoCode != null)
        {
          'kind': 'DISCOUNT',
          'refId': null,
          'grossMinor': -promoDiscountMinor,
          'netMinor': -promoDiscountMinor -
              (vatMinor - serviceVatMinor - addOnVatMinor),
          'vatMinor': vatMinor - serviceVatMinor - addOnVatMinor,
        },
    ],
  });
}

/// VAT contained within the UNDISCOUNTED wash price — what the SERVICE row
/// carries now that it states the pre-discount figure.
const serviceVatMinor = 1500; // 15% inclusive of 115.00

/// Booking repository that records the promo code each quote call carried.
///
/// [quoteFailure] lets a test reject a specific promo code OR a specific offer
/// id the way the backend does when it stops being applicable between the feed
/// and the tap (422 / 400 -> validation).
class RecordingBookingRepo extends BookingRepository {
  RecordingBookingRepo({
    this.expiredQuotes = true,
    this.quoteFailure,
    this.addOnGrossMinor = 0,
  }) : super(
        bookingsRemoteDataSource: BookingsRemoteDataSource(APIClient(Dio())),
      );

  /// What ONE selected add-on adds to the quoted gross, as an ADDON row.
  ///
  /// OFF by default: most tests here never touch the add-on grid, and a fixture
  /// that priced add-ons unconditionally would move totals they assert on.
  final int addOnGrossMinor;

  /// Answers every quote with an ALREADY-EXPIRED quote, so Confirm always takes
  /// the price-lock refresh branch.
  final bool expiredQuotes;

  /// Returns the failure a given promo code should be rejected with, or null to
  /// let the quote succeed.
  final Failure? Function(String? promoCode, String? offerId)? quoteFailure;

  /// One entry per [getQuote] call, holding the promo code it was given.
  final List<String?> quoteCalls = [];

  /// The offer id each [getQuote] call carried, index-aligned with
  /// [quoteCalls]. An offer-driven quote sends only the id; a typed code sends
  /// only the code — the pair is a 400 server-side.
  final List<String?> offerCalls = [];
  int paymentInitCalls = 0;

  @override
  Future<Either<Failure, QuoteModel>> getQuote({
    required String packageId,
    required double lat,
    required double lng,
    List<Map<String, dynamic>>? addOns,
    String? promoCode,
    String? offerId,
    int? pointsToApply,
    List<String> addOnIds = const [],
    int? carCount,
  }) async {
    quoteCalls.add(promoCode);
    offerCalls.add(offerId);
    await networkTick();
    final failure = quoteFailure?.call(promoCode, offerId);
    if (failure != null) return left(failure);
    return right(
      quotePayload(
        // The server resolves an offer to its linked code and echoes THAT — an
        // offer-driven quote never carries the code on the request, so a fake
        // that echoed only what it was given would report every offer quote as
        // carrying no promo at all.
        promoCode: promoCode ??
            (offerId == null ? null : offerResolvedPromoCode),
        quoteId: 'quote-${quoteCalls.length}',
        expired: expiredQuotes,
        addOnGrossMinor: addOnIds.isEmpty ? 0 : addOnGrossMinor,
      ),
    );
  }

  @override
  Future<Either<Failure, PaymentInitModel>> bookingPaymentInit({
    required String quoteId,
    required String scheduledAt,
    required List<Map<String, dynamic>> vehicles,
    required String attemptNonce,
    int? pointsToApply,
  }) async {
    paymentInitCalls++;
    await networkTick();
    // Stops the flow before the Moyasar SDK screen — the view treats a null
    // init as "abort quietly", which is all these tests need.
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
class UnusedSubmitStrategy implements BookingSubmitStrategy {
  @override
  Future<Either<Failure, BookingResponseModel>> submit({
    required BookingRepository repo,
    required BookingState state,
    String? moyasarPaymentId,
  }) async => left(ServerFailure('submit not exercised in this test'));
}
