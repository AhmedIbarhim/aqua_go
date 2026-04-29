import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 48),
        // Avatar Placeholder
        CircleAvatar(
          radius: 67,
          backgroundColor: context.colors.primary,
          child: Icon(Icons.person, size: 60, color: context.colors.background),
        ),
        const SizedBox(height: 16),
        // Name
        Text(
          'فيصل محمد',
          style: AppTextStyles.bold23.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        // Phone
        Text(
          '+966 123333478',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
        ),
        const SizedBox(height: 32),
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                    LocaleKeys.profile_account_info.tr(),
                    context,
                  ),
                  const SizedBox(height: 8),
                  _buildProfileItem(
                    context,
                    title: LocaleKeys.profile_add_email.tr(),
                    icon: AppAssets.mail,
                  ),
                  const SizedBox(height: 8),
                  _buildProfileItem(
                    context,
                    title: '+966 123445598',
                    icon: AppAssets.phone,
                    isVerified: true,
                  ),
                  const SizedBox(height: 8),
                  _buildProfileItem(
                    context,
                    title: LocaleKeys.profile_my_addresses.tr(),
                    icon: AppAssets.location,
                  ),
                  const SizedBox(height: 8),
                  _buildProfileItem(
                    context,
                    title: LocaleKeys.profile_my_wallet.tr(),
                    icon: AppAssets.wallet,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    LocaleKeys.profile_about_app.tr(),
                    context,
                  ),
                  const SizedBox(height: 8),
                  _buildProfileItem(
                    context,
                    title: LocaleKeys.profile_about_us.tr(),
                    icon: AppAssets.aboutUs,
                  ),
                  const SizedBox(height: 8),
                  _buildProfileItem(
                    context,
                    title: LocaleKeys.profile_settings.tr(),
                    icon: AppAssets.settings,
                    onTap: () {
                      context.pushNamed(Routes.settings);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildProfileItem(
                    context,
                    title: LocaleKeys.profile_technical_support.tr(),
                    icon: AppAssets.support,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.medium14.copyWith(
        color: context.colors.textSecondary,
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required String title,
    required String icon,
    bool isVerified = false,
    void Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.cardBackGround,
          border: Border.all(color: context.colors.borderSecondary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                SvgPicture.asset(
                  icon,
                  colorFilter: ColorFilter.mode(
                    context.colors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
            if (isVerified)
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: context.colors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'موثق',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: context.colors.success,
                    ),
                  ),
                ],
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
