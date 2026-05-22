import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/route/routes.dart';

import '../widgets/profile_tile.dart';

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
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    // Scaling helpers
    double sw(double width) => (width / 414) * screenWidth;
    double sh(double height) => (height / 896) * screenHeight;

    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(title: LocaleKeys.profile_settings.tr()),
      body: Column(
        children: [
          SizedBox(height: sh(16)),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sw(24)),
                  topRight: Radius.circular(sw(24)),
                ),
              ),
              padding: EdgeInsets.all(sw(24)),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      LocaleKeys.settings_more_settings.tr(),
                      context,
                    ),
                    SizedBox(height: sh(8)),
                    ProfileTile(
                      title: LocaleKeys.settings_language.tr(),
                      icon: AppAssets.language,

                      onTap: () {
                        context.pushNamed(Routes.languageSelect);
                      },
                    ),
                    SizedBox(height: sh(8)),
                    ProfileTile(
                      title: LocaleKeys.settings_privacy_policy.tr(),
                      icon: AppAssets.privacy,
                      onTap: () {
                        context.pushNamed(Routes.privacyPolicy);
                      },
                    ),
                    SizedBox(height: sh(8)),
                    ProfileTile(
                      title: LocaleKeys.settings_terms_and_conditions.tr(),
                      icon: AppAssets.terms,
                      onTap: () {
                        context.pushNamed(Routes.termsAndConditions);
                      },
                    ),
                    // SizedBox(height: sh(8)),
                    // BlocBuilder<ThemeCubit, ThemeState>(
                    //   builder: (context, themeState) {
                    //     final isDarkMode =
                    //         themeState.themeMode == ThemeMode.dark;
                    //     return ProfileTile(
                    //       title: LocaleKeys.settings_dark_mode.tr(),
                    //       icon: AppAssets.darkMode,
                    //       hasToggle: true,
                    //       toggleValue: isDarkMode,
                    //       onToggleChanged: (val) {
                    //         context.read<ThemeCubit>().toggleTheme(val);
                    //       },
                    //     );
                    //   },
                    // ),
                    SizedBox(height: sh(24)),
                    _buildSectionTitle(
                      LocaleKeys.settings_get_notifications.tr(),
                      context,
                    ),
                    SizedBox(height: sh(8)),
                    ProfileTile(
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
                    SizedBox(height: sh(8)),
                    ProfileTile(
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
                    SizedBox(height: sh(8)),
                    ProfileTile(
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
                    SizedBox(height: sh(8)),
                    ProfileTile(
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
                    SizedBox(height: sh(24)),
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
}
