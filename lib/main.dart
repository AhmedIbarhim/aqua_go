import 'package:aqua_go/app.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/bloc_observer.dart';
import 'core/config/controllers/language_controller/language_cubit.dart';
import 'core/config/controllers/theme_controller/theme_cubit.dart';

import 'core/config/local_storage/shared_prefs.dart';
import 'core/constants.dart';
import 'generated/codegen_loader.g.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServiceLocator();
  await EasyLocalization.ensureInitialized();
  await SharedPrefs.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final String savedLang = SharedPrefs.getString(kLanguage);
  final Locale startLocale = savedLang.isEmpty
      ? const Locale('ar')
      : Locale(savedLang);

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
        ],
        child: const MyApp(),
      ),
    ),
  );
}
