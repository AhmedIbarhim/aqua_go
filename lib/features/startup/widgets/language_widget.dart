import 'package:aqua_go/core/config/controllers/language_controller/language_cubit.dart';
import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg_flutter.dart';

import '../../../core/extentions/context_extentions.dart';

class LanguageWidget extends StatelessWidget {
  const LanguageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LanguageCubit>().state.locale;
    final isArabic = currentLocale.languageCode == 'ar';
    final targetLanguageName = isArabic ? 'الانجليزية' : 'Arabic';
    final targetFlag = isArabic ? AppAssets.usFlag : AppAssets.ksaFlag;

    return GestureDetector(
      onTap: () => context.read<LanguageCubit>().toggleLanguage(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: darkAppColors.contentTertiary),
          color: darkAppColors.themeOpositeColor.withValues(alpha: 0.8),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (context.isEn) ...[
                CircleAvatar(
                  radius: 8,
                  backgroundColor: darkAppColors.themeOpositeColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SvgPicture.asset(
                      targetFlag,
                      width: 16,
                      height: 16,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              if (context.isAr) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 8,
                  backgroundColor: darkAppColors.themeOpositeColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SvgPicture.asset(
                      targetFlag,
                      width: 16,
                      height: 16,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              Text(
                targetLanguageName,
                style: AppTextStyles.regular14.copyWith(
                  color: darkAppColors.contentSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
