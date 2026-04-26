import 'package:aqua_go/core/controllers/language_controller/language_cubit.dart';
import 'package:aqua_go/core/themes/app_colors.dart';
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
          border: Border.all(color: AppColors.blueGrey50),
          color: AppColors.white.withValues(alpha: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (context.isEn) ...[
              CircleAvatar(
                radius: 8,
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
              style: const TextStyle(
                color: AppColors.contentSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (context.isAr) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 8,
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
            ],
          ],
        ),
      ),
    );
  }
}
