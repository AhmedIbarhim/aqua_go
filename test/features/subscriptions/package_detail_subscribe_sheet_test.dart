import 'package:aqua_go/core/config/controllers/language_controller/language_cubit.dart';
import 'package:aqua_go/core/config/controllers/theme_controller/theme_cubit.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/config/session/session_state.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/core/route/app_router.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:aqua_go/features/auth/data/models/user_model.dart';
import 'package:aqua_go/features/home/data/data_source/packages_remote_data_source.dart';
import 'package:aqua_go/features/home/data/models/package_model.dart';
import 'package:aqua_go/features/home/data/repos/packages_repository.dart';
import 'package:aqua_go/features/home/presentation/controllers/package_detail_controller/package_detail_cubit.dart';
import 'package:aqua_go/features/home/presentation/controllers/packages_controller/packages_cubit.dart';
import 'package:aqua_go/features/home/presentation/views/packages_view.dart';
import 'package:aqua_go/features/home/presentation/widgets/package_card.dart';
import 'package:aqua_go/features/subscriptions/data/data_sources/subscriptions_remote_data_source.dart';
import 'package:aqua_go/features/subscriptions/data/models/subscription_response_model/subscription_response_model.dart';
import 'package:aqua_go/features/subscriptions/data/repos/subscriptions_repository.dart';
import 'package:aqua_go/features/subscriptions/presentation/controllers/subscriptions_controller/subscriptions_cubit.dart';
import 'package:aqua_go/features/subscriptions/presentation/widgets/package_subscribtion_bottom_sheet.dart';
import 'package:aqua_go/generated/codegen_loader.g.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [PackagesRepository] that answers both reads from memory, so the package
/// screens can be pumped without a network.
class _ScriptedPackagesRepository extends PackagesRepository {
  _ScriptedPackagesRepository(this._package)
    : super(PackagesRemoteDataSource(APIClient(Dio())));

  final PackageModel _package;

  @override
  Future<Either<Failure, List<PackageModel>>> fetchPackages() async =>
      Right([_package]);

  @override
  Future<Either<Failure, PackageModel>> fetchPackageById(
    String packageId,
  ) async => Right(_package);
}

class _ScriptedSubscriptionsRepository extends SubscriptionsRepository {
  _ScriptedSubscriptionsRepository()
    : super(SubscriptionsRemoteDataSource(APIClient(Dio())));

  @override
  Future<Either<Failure, List<SubscriptionResponseModel>>>
  fetchActiveSubscriptions({int? limit, String? cursor, String? status}) async =>
      const Right(<SubscriptionResponseModel>[]);
}

PackageModel goldPackage({String id = 'pkg-77'}) => PackageModel(
  id: id,
  nameAr: 'الباقة الذهبية',
  nameEn: 'Gold package',
  descriptionAr: 'اربع غسلات',
  descriptionEn: 'Four washes',
  numWashes: 4,
  validityDays: 30,
  priceMinor: 24900,
  currency: 'SAR',
  maxActivePerCustomer: 1,
  allowScheduleLater: true,
  active: true,
  bundledServiceIds: const [],
  createdAt: '',
  updatedAt: '',
  version: 1,
  imageUrl: '',
  isPopular: false,
  carsPerWash: 1,
  effectiveFromAt: '',
  addons: const [],
);

/// Advances past the route transition and the sheet animation WITHOUT waiting
/// for the tree to go quiet: the package screens render a shimmer skeleton
/// whose animation never ends, so `pumpAndSettle` would time out.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

/// Pumps the REAL router — `AppRouter.generateRoute` — under a bare home, so a
/// named push lands on a root-navigator route that is a sibling of the pushing
/// route, exactly as it does in the app.
Future<void> pumpRouterApp(WidgetTester tester) async {
  await CacheClient.setString(kLanguage, 'en');
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('en'),
      assetLoader: const CodegenLoader(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LanguageCubit()),
          BlocProvider(create: (_) => ThemeCubit()),
        ],
        child: Builder(
          builder: (context) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            theme: ThemeData(
              extensions: <ThemeExtension<dynamic>>[darkAppColors],
            ),
            onGenerateRoute: AppRouter.generateRoute,
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  key: const ValueKey('go'),
                  onPressed: () => Navigator.of(context).pushNamed(
                    Routes.packageDetail,
                    arguments: PackageDetailArgs(packageId: 'pkg-77'),
                  ),
                  child: const Text('go'),
                ),
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
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await CacheClient.init();
    await EasyLocalization.ensureInitialized();
    currentUser.value = const UserModel(id: 'customer-1');

    final packages = _ScriptedPackagesRepository(goldPackage());
    locator.registerLazySingleton<PackagesRepository>(() => packages);
    locator.registerLazySingleton<SubscriptionsRepository>(
      () => _ScriptedSubscriptionsRepository(),
    );
    locator.registerFactory<PackageDetailCubit>(
      () => PackageDetailCubit(packagesRepository: locator()),
    );
    locator.registerFactory<PackagesCubit>(
      () => PackagesCubit(packagesRepository: locator()),
    );
    locator.registerLazySingleton<SubscriptionsCubit>(
      () => SubscriptionsCubit(subscriptionsRepository: locator()),
    );
  });

  tearDown(() async {
    currentUser.value = null;
    await locator.reset();
  });

  testWidgets(
    'the offer path — a PACKAGE offer pushes Routes.packageDetail — opens the '
    'subscription sheet instead of throwing ProviderNotFoundException',
    (tester) async {
      await pumpRouterApp(tester);

      // What OfferDetailView does on its primary action: a bare named push of
      // Routes.packageDetail onto the root navigator.
      await tester.tap(find.byKey(const ValueKey('go')));
      await settle(tester);
      expect(find.byType(PackageCard), findsOneWidget);

      await tester.tap(find.byType(PackageCard));
      await settle(tester);

      expect(
        tester.takeException(),
        isNull,
        reason: 'the subscribe tap must not throw — the route that renders '
            'PackageCard has to carry SubscriptionsCubit down with it',
      );
      expect(find.byType(PackageSubscribtionBottomSheet), findsOneWidget);
    },
  );

  testWidgets(
    'the working path — Routes.packages — still opens the same sheet',
    (tester) async {
      await pumpRouterApp(tester);

      final context = tester.element(find.byKey(const ValueKey('go')));
      Navigator.of(context).pushNamed(Routes.packages);
      await settle(tester);
      expect(find.byType(PackagesView), findsOneWidget);

      await tester.tap(find.byType(PackageCard).first);
      await settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(PackageSubscribtionBottomSheet), findsOneWidget);
    },
  );
}
