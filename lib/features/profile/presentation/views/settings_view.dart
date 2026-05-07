import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_go/core/config/controllers/theme_controller/theme_cubit.dart';

import '../../../../core/route/routes.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isMarketingNotif = true;
  bool isWhatsapp = true;
  bool isSms = true;
  bool isEmail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(title: LocaleKeys.profile_settings.tr()),
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      LocaleKeys.settings_more_settings.tr(),
                      context,
                    ),
                    const SizedBox(height: 8),
                    _buildSettingsItem(
                      context,
                      title: LocaleKeys.settings_language.tr(),
                      icon: AppAssets.language,
                      onTap: () {
                        context.pushNamed(Routes.languageSelect);
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSettingsItem(
                      context,
                      title: LocaleKeys.settings_privacy_policy.tr(),
                      icon: AppAssets.privacy,
                    ),
                    const SizedBox(height: 8),
                    _buildSettingsItem(
                      context,
                      title: LocaleKeys.settings_terms_and_conditions.tr(),
                      icon: AppAssets.terms,
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<ThemeCubit, ThemeState>(
                      builder: (context, themeState) {
                        final isDarkMode =
                            themeState.themeMode == ThemeMode.dark;
                        return _buildSettingsItem(
                          context,
                          title: LocaleKeys.settings_dark_mode.tr(),
                          icon: AppAssets.darkMode,
                          hasToggle: true,
                          toggleValue: isDarkMode,
                          onToggleChanged: (val) {
                            context.read<ThemeCubit>().toggleTheme(val);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      LocaleKeys.settings_get_notifications.tr(),
                      context,
                    ),
                    const SizedBox(height: 8),
                    _buildSettingsItem(
                      context,
                      title: LocaleKeys.settings_marketing_notification.tr(),
                      icon: AppAssets.notification,
                      hasToggle: true,
                      toggleValue: isMarketingNotif,
                      onToggleChanged: (val) {
                        setState(() {
                          isMarketingNotif = val;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSettingsItem(
                      context,
                      title: LocaleKeys.settings_whatsapp_messages.tr(),
                      icon: AppAssets.whatsppOutlined,
                      hasToggle: true,
                      toggleValue: isWhatsapp,
                      onToggleChanged: (val) {
                        setState(() {
                          isWhatsapp = val;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSettingsItem(
                      context,
                      title: LocaleKeys.settings_sms_messages.tr(),
                      icon: AppAssets.sms,
                      hasToggle: true,
                      toggleValue: isSms,
                      onToggleChanged: (val) {
                        setState(() {
                          isSms = val;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSettingsItem(
                      context,
                      title: LocaleKeys.settings_email_notifications.tr(),
                      icon: AppAssets.mail,
                      hasToggle: true,
                      toggleValue: isEmail,
                      onToggleChanged: (val) {
                        setState(() {
                          isEmail = val;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildSettingsItem(
    BuildContext context, {
    required String title,
    required String icon,
    bool hasToggle = false,
    bool toggleValue = false,
    ValueChanged<bool>? onToggleChanged,
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
                SizedBox(
                  width: 24,
                  height: 24,
                  child: SvgPicture.asset(
                    icon,
                    colorFilter: ColorFilter.mode(
                      context.colors.textPrimary,
                      BlendMode.srcIn,
                    ),
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
            if (hasToggle)
              SizedBox(
                height: 24,
                child: Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: toggleValue,
                    onChanged: onToggleChanged,
                    activeThumbColor: context.colors.screenBG,
                    activeTrackColor: context.colors.primary,
                    inactiveThumbColor: context.colors.contentDisabled,
                    inactiveTrackColor: context.colors.defaultSubtle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
