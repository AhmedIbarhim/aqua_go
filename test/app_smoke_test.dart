import 'package:aqua_go/app.dart';
import 'package:aqua_go/core/config/controllers/connectivity_controller/connectivity_cubit.dart';
import 'package:aqua_go/core/config/controllers/language_controller/language_cubit.dart';
import 'package:aqua_go/core/config/controllers/theme_controller/theme_cubit.dart';
import 'package:aqua_go/core/components/floating_control_widgets.dart';
import 'package:aqua_go/core/components/offline_indicator.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:aqua_go/features/auth/data/repos/auth_repository.dart';
import 'package:aqua_go/features/auth/data/services/auth_service.dart';
import 'package:aqua_go/features/startup/views/onboarding_view.dart';
import 'package:aqua_go/features/startup/views/splash_view.dart';
import 'package:aqua_go/generated/codegen_loader.g.dart';
import 'package:aqua_go/main/app_configs.dart';
import 'package:dio/dio.dart';
// `intl` (re-exported by easy_localization) ships its own TextDirection, which
// would shadow the dart:ui one the Directionality assertion needs.
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cold-start smoke cover for the REAL app root.
///
/// [MyApp] is the exact widget `launchApp` hands to `runApp`, wrapped here in
/// the same `EasyLocalization` + cubit scaffolding that `launchApp` builds. So
/// this is the only test that proves the whole shell composes end to end:
/// the persisted locale reaching `Directionality`, `ThemeCubit` reaching the
/// [AppColors] theme extension, the fixed text scaler, the offline indicator
/// riding above every route, and the router resolving the initial route.
///
/// It also covers the install-marker gate: SharedPrefs is wiped on reinstall
/// while the Keychain survives, so an absent marker must send a cold start to
/// the pre-auth flow rather than trusting a stale token.
void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await CacheClient.init();
    await EasyLocalization.ensureInitialized();
    // MyApp's builder gates the floating dev switchers on the environment,
    // so the shell cannot mount without AppConfigs. Pin it to prod — that is
    // the shell shape that ships.
    locator.registerSingleton<AppConfigs>(
      AppConfigs.forEnvironment(AppEnvironment.prod),
    );
    // SplashView resolves AuthRepository off the locator once the splash
    // delay lapses. The purge path it takes here never reaches the network,
    // so a bare Dio is enough to satisfy the graph.
    locator.registerLazySingleton<AuthRepository>(
      () => AuthRepository(AuthService(APIClient(Dio()))),
    );
  });

  tearDown(() async {
    await locator.reset();
  });

  /// Builds the production widget tree exactly as `launchApp` does.
  Future<void> pumpAppRoot(WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ar'),
        startLocale: const Locale('ar'),
        assetLoader: const CodegenLoader(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => LanguageCubit()),
            BlocProvider(create: (_) => ThemeCubit()),
            BlocProvider(create: (_) => ConnectivityCubit()),
          ],
          child: const MyApp(),
        ),
      ),
    );
    // EasyLocalization resolves its bundle on a future before it yields the
    // child, so the first frame is its placeholder.
    await tester.pump();
    await tester.pump();
  }

  /// Drains the 3s splash delay and the resulting navigation so no timer is
  /// left pending when the test ends.
  Future<void> settleSplash(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  testWidgets('app root composes the shell and lands on the splash screen', (
    tester,
  ) async {
    await pumpAppRoot(tester);

    // The router resolved the initial route ('/') through AppRouter.
    expect(find.byType(SplashView), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Aqua Go');
    expect(app.locale, const Locale('ar'));
    expect(app.navigatorKey, isNotNull);

    final splashContext = tester.element(find.byType(SplashView));

    // Arabic default locale must reach the tree as RTL (R-12).
    expect(Directionality.of(splashContext), TextDirection.rtl);

    // ThemeCubit defaults to dark, and the AppColors extension must be
    // installed on whichever ThemeData wins — every screen reads it via
    // context.colors and would throw a null-check without it.
    expect(Theme.of(splashContext).extension<AppColors>(), darkAppColors);

    // The app pins text scaling so KSA-Arabic layouts cannot be blown apart
    // by an OS-level font-size setting.
    expect(
      MediaQuery.textScalerOf(splashContext),
      const TextScaler.linear(1.0),
    );

    // The offline banner is mounted above the router, not inside a route,
    // so it survives every navigation.
    expect(find.byType(OfflineIndicator), findsOneWidget);

    // The floating theme/language switchers are a dev affordance only — they
    // must never reach a prod build.
    expect(find.byType(FloatingThemeSwitcher), findsNothing);
    expect(find.byType(FloatingLanguageSwitcher), findsNothing);

    await settleSplash(tester);
  });

  testWidgets(
    'cold start with no install marker routes to the pre-auth onboarding flow',
    (tester) async {
      // A reinstall leaves SharedPrefs empty (no install marker, no
      // kNotFirstUse), which is what setUp() seeds.
      expect(CacheClient.getBool(kSessionInstallMarker), isFalse);

      await pumpAppRoot(tester);
      expect(find.byType(SplashView), findsOneWidget);

      await settleSplash(tester);

      expect(find.byType(OnboardingView), findsOneWidget);
      expect(find.byType(SplashView), findsNothing);
      // The gate must have armed the marker so the next cold start trusts
      // the Keychain again.
      expect(CacheClient.getBool(kSessionInstallMarker), isTrue);
    },
  );
}
