import 'package:aqua_go/core/controllers/language_controller/language_cubit.dart';
import 'package:aqua_go/core/controllers/theme_controller/theme_cubit.dart';
import 'package:aqua_go/core/route/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/themes/app_colors_extension.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, languageState) {
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              title: 'Aqua Go',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: languageState.locale,
              themeMode: themeState.themeMode,
              color: themeState.themeMode == ThemeMode.light
                  ? lightAppColors.primary
                  : darkAppColors.primary,
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: lightAppColors.screenBG,
                primaryColor: lightAppColors.primary,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: lightAppColors.primary,
                  brightness: Brightness.light,
                ),
                extensions: const <ThemeExtension<dynamic>>[lightAppColors],
                textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
                  Theme.of(context).textTheme.apply(
                    displayColor: lightAppColors.textPrimary,
                    bodyColor: lightAppColors.textPrimary,
                  ),
                ),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: darkAppColors.screenBG,
                primaryColor: darkAppColors.primary,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: darkAppColors.primary,
                  brightness: Brightness.dark,
                ),
                extensions: const <ThemeExtension<dynamic>>[darkAppColors],
                textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
                  Theme.of(context).textTheme.apply(
                    displayColor: darkAppColors.textPrimary,
                    bodyColor: darkAppColors.textPrimary,
                  ),
                ),
              ),
              onGenerateRoute: AppRouter.generateRoute,
            );
          },
        );
      },
    );
  }
}
