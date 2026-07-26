import 'package:aqua_go/core/config/bloc_observer.dart';
import 'package:aqua_go/core/config/controllers/connectivity_controller/connectivity_cubit.dart';
import 'package:aqua_go/core/config/controllers/language_controller/language_cubit.dart';
import 'package:aqua_go/core/config/controllers/theme_controller/theme_cubit.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/helpers/connectivity_helper.dart';
import 'package:aqua_go/features/auth/data/services/device_token_sync.dart';
import 'package:aqua_go/init_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:aqua_go/app.dart';
import 'package:aqua_go/firebase_options.dart';
import 'package:aqua_go/generated/codegen_loader.g.dart';

import 'app_configs.dart';

void launchApp(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  final configs = AppConfigs.forEnvironment(environment);
  ConnectivityHelper().init();
  await initServiceLocator(configs);
  await EasyLocalization.ensureInitialized();
  await CacheClient.init();
  Bloc.observer = AppBlocObserver();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    /* proceed without firebase */
  }
  try {
    await initNotifications();
  } catch (e) {
    /* proceed without push */
  }
  // Fire-and-forget: sync FCM token if user is already logged in from a
  // previous session. No await — must not block app startup.
  syncDeviceToken();
  // ONE locale computation, shared by easy_localization's startLocale and the
  // Intl pin below, so the two can never desync.
  final Locale startLocale = LanguageCubit.initialLocale;

  // Pin intl to the app's language. Without this, `EasyLocalization
  // .ensureInitialized()` leaves `Intl.systemLocale` holding the DEVICE OS
  // locale and `Intl.defaultLocale` null, so every `DateFormat` built without
  // an explicit locale formats against the phone rather than the language the
  // customer picked in-app. Re-pinned on every language change in
  // `LanguageCubit._applyLocale`.
  Intl.defaultLocale = startLocale.languageCode;

  Bloc.observer = AppBlocObserver();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: startLocale,
      assetLoader: const CodegenLoader(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => LanguageCubit()),
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(create: (context) => ConnectivityCubit()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
