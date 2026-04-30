import 'package:aqua_go/app.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/controllers/language_controller/language_cubit.dart';
import 'core/controllers/theme_controller/theme_cubit.dart';

import 'core/config/shared_prefs.dart';
import 'core/constants.dart';
import 'generated/codegen_loader.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await SharedPrefs.init();
  final String savedLang = SharedPrefs.getString(kLanguage);
  final Locale startLocale = savedLang.isEmpty
      ? const Locale('ar')
      : Locale(savedLang);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: startLocale,
      assetLoader: const CodegenLoader(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LanguageCubit(),
          ),
          BlocProvider(
            create: (context) => ThemeCubit(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
