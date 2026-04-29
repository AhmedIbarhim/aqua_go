import 'package:aqua_go/core/controllers/language_controller/language_cubit.dart';
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
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: state.locale,
          // themeMode: ThemeMode.system,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: lightAppColors.screenBG,
            primaryColor: lightAppColors.primary,
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
  }
}
