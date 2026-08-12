import 'package:aqua_go/core/config/controllers/language_controller/language_cubit.dart';
import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg_flutter.dart';

class LanguageWidget extends StatefulWidget {
  const LanguageWidget({super.key});

  @override
  State<LanguageWidget> createState() => _LanguageWidgetState();
}

class _LanguageWidgetState extends State<LanguageWidget> {
  bool _isOpened = false;

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LanguageCubit>().state.locale;

    return PopupMenuButton<String>(
      onOpened: () {
        setState(() {
          _isOpened = true;
        });
      },
      onCanceled: () {
        setState(() {
          _isOpened = false;
        });
      },
      onSelected: (String langCode) {
        setState(() {
          _isOpened = false;
        });
        if (currentLocale.languageCode != langCode) {
          context.read<LanguageCubit>().changeLanguage(context, langCode);
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: lightAppColors.background,
      elevation: 4,
      offset: const Offset(0, 40),
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'en',
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'English',
                style: AppTextStyles.regular14.copyWith(
                  color: currentLocale.languageCode == 'en'
                      ? lightAppColors.primary
                      : lightAppColors.textSecondary,
                ),
              ),
            ),
          ),
          PopupMenuItem<String>(
            value: 'ar',
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'العربية',
                style: AppTextStyles.regular14.copyWith(
                  color: currentLocale.languageCode == 'ar'
                      ? lightAppColors.primary
                      : lightAppColors.textSecondary,
                ),
              ),
            ),
          ),
        ];
      },
      child: SvgPicture.asset(
        AppAssets.locale,
        width: 18,
        height: 18,
        colorFilter: ColorFilter.mode(
          _isOpened ? lightAppColors.primary : darkAppColors.contentDisabled,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
