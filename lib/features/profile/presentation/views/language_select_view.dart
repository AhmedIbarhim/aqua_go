import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/components/custom_radio_widget.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/config/controllers/language_controller/language_cubit.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../generated/locale_keys.g.dart';

class LanguageSelectView extends StatelessWidget {
  const LanguageSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;

    return BlocListener<LanguageCubit, LanguageState>(
      listener: (context, state) {
        if (state is LanguageLoading) {
          context.showLoadingOverlay();
        } else {
          context.hideLoadingOverlay();
        }

        if (state is LanguageError) {
          context.showErrorSnackBar(state.message);
        } else if (state is LanguageChanged) {
          context.showSuccessSnackBar(
            context.isAr
                ? 'تم تحديث اللغة بنجاح'
                : 'Language updated successfully',
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.screenBG,
        appBar: GenericAppBar(title: LocaleKeys.settings_language.tr()),
        body: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                height: double.infinity,
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    _LanguageItem(
                      title: LocaleKeys.language_arabic.tr(),
                      flag: AppAssets.ksaFlag,
                      isSelected: currentLocale.languageCode == kArabicLang,
                      onTap: () {
                        if (currentLocale.languageCode != kArabicLang) {
                          context.read<LanguageCubit>().changeLanguage(
                            context,
                            kArabicLang,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _LanguageItem(
                      title: LocaleKeys.language_english.tr(),
                      flag: AppAssets.usFlag,
                      isSelected: currentLocale.languageCode == kEnglishLang,
                      onTap: () {
                        if (currentLocale.languageCode != kEnglishLang) {
                          context.read<LanguageCubit>().changeLanguage(
                            context,
                            kEnglishLang,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageItem extends StatelessWidget {
  final String title;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageItem({
    required this.title,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.cardBackGround,
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.borderSecondary,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SvgPicture.asset(
                flag,
                width: 24,
                height: 16,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.medium16.copyWith(
                color: context.colors.textPrimary,
              ),
            ),

            const Spacer(),
            CustomRadioWidget(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}
