import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.support_title.tr(),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildSupportItem(
                    context: context,
                    title: LocaleKeys.support_faq.tr(),
                    iconPath: AppAssets.question,
                    onTap: () {
                      // TODO: Navigate to FAQ
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSupportItem(
                    context: context,
                    title: LocaleKeys.support_complaint_log.tr(),
                    iconPath: AppAssets.documentCopy,
                    onTap: () {
                      // TODO: Navigate to Complaint Log
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSupportItem(
                    context: context,
                    title: LocaleKeys.support_whatsapp_contact.tr(),
                    iconPath: AppAssets.whatsapp,
                    onTap: () {
                      // TODO: Open WhatsApp link
                    },
                    textColor: const Color(0xFF2A8D36),
                    borderColor: const Color(0xFF2A8D36),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem({
    required BuildContext context,
    required String title,
    required String iconPath,
    required VoidCallback onTap,
    Color? textColor,
    Color? borderColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.cardBackGround,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ?? context.colors.borderSecondary,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(iconPath, width: 24, height: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.start,
                style: AppTextStyles.regular16.copyWith(
                  color: textColor ?? context.colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
