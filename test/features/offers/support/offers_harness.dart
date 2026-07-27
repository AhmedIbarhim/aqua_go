import 'package:aqua_go/core/config/controllers/language_controller/language_cubit.dart';
import 'package:aqua_go/core/config/controllers/theme_controller/theme_cubit.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/config/session/session_state.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:aqua_go/core/utils/saudi_wire_format.dart';
import 'package:aqua_go/features/auth/data/models/user_model.dart';
import 'package:aqua_go/features/auth/data/repos/auth_repository.dart';
import 'package:aqua_go/features/auth/data/services/auth_service.dart';
import 'package:aqua_go/features/offers/data/data_source/offers_remote_data_source.dart';
import 'package:aqua_go/features/offers/data/models/customer_offer_model.dart';
import 'package:aqua_go/features/offers/data/repos/offers_repository.dart';
import 'package:aqua_go/features/offers/presentation/controllers/offers_controller/offers_cubit.dart';
import 'package:aqua_go/generated/codegen_loader.g.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An [OffersRepository] whose two reads are scripted per call, so a test can
/// say "the list loads, then the re-validation 404s" without a network.
class ScriptedOffersRepository extends OffersRepository {
  ScriptedOffersRepository({
    Either<Failure, List<CustomerOfferModel>>? listResult,
    Either<Failure, CustomerOfferModel>? detailResult,
  })  : _listResult = listResult ?? const Right(<CustomerOfferModel>[]),
        _detailResult = detailResult ??
            const Left(ServerFailure('unset', type: FailureType.notFound)),
        super(OffersRemoteDataSource(APIClient(Dio())));

  Either<Failure, List<CustomerOfferModel>> _listResult;
  Either<Failure, CustomerOfferModel> _detailResult;

  int listCalls = 0;
  final List<String> detailCalls = <String>[];

  /// Swaps what the NEXT list read answers — used to prove a retry actually
  /// re-fetches rather than replaying a cached failure.
  void answerListWith(Either<Failure, List<CustomerOfferModel>> next) =>
      _listResult = next;

  void answerDetailWith(Either<Failure, CustomerOfferModel> next) =>
      _detailResult = next;

  @override
  Future<Either<Failure, List<CustomerOfferModel>>> fetchOffers() async {
    listCalls++;
    return _listResult;
  }

  @override
  Future<Either<Failure, CustomerOfferModel>> fetchOffer(String offerId) async {
    detailCalls.add(offerId);
    return _detailResult;
  }
}

/// A promo-code offer with distinct AR and EN banners (AC-EXT-08).
CustomerOfferModel promoOffer({
  String id = 'offer-1',
  String code = 'WELCOME20',
  int minOrderMinor = 0,
  DateTime? endsAt,
}) =>
    CustomerOfferModel(
      id: id,
      offerType: 'PROMO_CODE',
      titleAr: 'عرض الترحيب',
      titleEn: 'Welcome offer',
      descriptionAr: 'خصم على أول حجز',
      descriptionEn: 'A discount on your first booking',
      bannerArUrl: 'https://cdn.example/$id-ar.png',
      bannerEnUrl: 'https://cdn.example/$id-en.png',
      endsAt: endsAt ?? saudiNow().add(const Duration(days: 30)),
      terms: OfferTermsModel(
        promoCode: code,
        discountType: 'PERCENTAGE',
        configuredValue: 20,
        minOrderMinor: minOrderMinor,
      ),
    );

/// An offer whose `terms` payload arrived without the identity field its type
/// needs — no `promoCode` on a PROMO_CODE offer, no `packageId` on a PACKAGE
/// one. Built through `fromJson` on purpose: that is a read-reconstruction
/// path, so it degrades the missing field to null rather than throwing, which
/// makes this a supported input the primary action has to answer for.
CustomerOfferModel offerWithoutItsLink({
  required String id,
  required String offerType,
}) =>
    CustomerOfferModel.fromJson({
      'id': id,
      'offerType': offerType,
      'titleAr': 'عرض',
      'titleEn': 'Offer',
      'descriptionAr': 'وصف',
      'descriptionEn': 'Description',
      'endsAt': toWireDateTime(saudiNow().add(const Duration(days: 30))),
      'terms': {'discountType': 'PERCENTAGE'},
    });

/// A promo-code offer scoped to named services and zones (UCC23 step 6 / A5).
CustomerOfferModel restrictedPromoOffer({String id = 'offer-restricted'}) =>
    CustomerOfferModel(
      id: id,
      offerType: 'PROMO_CODE',
      titleAr: 'عرض وسط جدة',
      titleEn: 'Central Jeddah offer',
      descriptionAr: 'خصم على الغسيل الممتاز',
      descriptionEn: 'A discount on the premium wash',
      bannerArUrl: 'https://cdn.example/$id-ar.png',
      bannerEnUrl: 'https://cdn.example/$id-en.png',
      endsAt: saudiNow().add(const Duration(days: 30)),
      terms: const OfferTermsModel(
        promoCode: 'CENTRAL',
        discountType: 'PERCENTAGE',
        configuredValue: 10,
        applicableServiceNamesAr: ['غسيل ممتاز'],
        applicableServiceNamesEn: ['Premium Wash'],
        applicableZoneNamesAr: ['وسط جدة'],
        applicableZoneNamesEn: ['Central Jeddah'],
      ),
    );

CustomerOfferModel packageOffer({
  String id = 'offer-pkg',
  String packageId = 'pkg-1',
  DateTime? endsAt,
}) =>
    CustomerOfferModel(
      id: id,
      offerType: 'PACKAGE',
      titleAr: 'الباقة الذهبية',
      titleEn: 'Gold package',
      descriptionAr: 'أربع غسلات',
      descriptionEn: 'Four washes',
      bannerArUrl: 'https://cdn.example/$id-ar.png',
      bannerEnUrl: 'https://cdn.example/$id-en.png',
      endsAt: endsAt ?? saudiNow().add(const Duration(days: 30)),
      terms: OfferTermsModel(
        packageId: packageId,
        packageNameAr: 'الباقة الذهبية',
        packageNameEn: 'Gold package',
        packagePriceMinor: 24900,
        packageNumWashes: 4,
        packageValidityDays: 30,
      ),
    );

/// Boots the storage + locator the offers surfaces reach into.
///
/// `FetchUserData.isGuest()` consults BOTH the reactive [currentUser] notifier
/// and `AuthRepository.getUser()`, so both have to exist for the A4 prompt to
/// resolve. With mocked-empty SharedPreferences the repository answers null,
/// which is the guest case; [signIn] flips the notifier for the other half.
Future<void> bootOffersTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues({});
  await CacheClient.init();
  await EasyLocalization.ensureInitialized();
  currentUser.value = null;
  if (!locator.isRegistered<AuthRepository>()) {
    locator.registerLazySingleton<AuthRepository>(
      () => AuthRepository(AuthService(APIClient(Dio()))),
    );
  }
}

void signIn() => currentUser.value = const UserModel(id: 'customer-1');

/// Pumps [child] inside the same locale, theme and cubit scaffolding the real
/// app builds, at [locale], with [cubit] provided above it.
///
/// [onGenerateRoute] lets a test observe a named push (the package route, the
/// login route) without dragging the whole router in.
Future<void> pumpOffersSurface(
  WidgetTester tester, {
  required Widget child,
  required OffersCubit cubit,
  Locale locale = const Locale('en'),
  Route<dynamic>? Function(RouteSettings settings)? onGenerateRoute,
}) async {
  // context.isAr reads LanguageCubit, which seeds itself from the persisted
  // preference — NOT from EasyLocalization's startLocale. Both have to agree or
  // the widgets pick their strings from one locale and their direction from the
  // other.
  await CacheClient.setString(kLanguage, locale.languageCode);
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: locale,
      assetLoader: const CodegenLoader(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LanguageCubit()),
          // The shimmer skeletons read ThemeCubit through context.isDarkTheme
          // to pick their base and highlight colours, so the loading state
          // cannot be pumped without it.
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider<OffersCubit>.value(value: cubit),
        ],
        child: Builder(
          builder: (context) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            theme: ThemeData(extensions: <ThemeExtension<dynamic>>[darkAppColors]),
            onGenerateRoute: onGenerateRoute,
            home: child,
          ),
        ),
      ),
    ),
  );
  // EasyLocalization resolves its bundle on a future before yielding the child.
  await tester.pump();
  await tester.pump();
}
