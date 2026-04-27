import 'package:aqua_go/core/controllers/language_controller/language_cubit.dart';
import 'package:aqua_go/core/route/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/themes/app_colors.dart';
import 'features/layout/presentation/views/main_layout.dart';

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
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.screenBG,
            primaryColor: AppColors.primary,
            textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
              Theme.of(context).textTheme.apply(
                displayColor: AppColors.white,
                bodyColor: AppColors.white,
              ),
            ),
          ),
          home: const MainLayout(),
          // onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}
