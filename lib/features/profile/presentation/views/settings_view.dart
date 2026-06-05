import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../../core/route/routes.dart';
import '../../data/models/notification_preferences_model.dart';
import '../../controllers/notification_preferences_cubit/notification_preferences_cubit.dart';

import '../widgets/profile_tile.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isWhatsapp = true;

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return BlocProvider(
      create: (context) =>
          locator<NotificationPreferencesCubit>()..getNotificationPreferences(),
      child: BlocListener<NotificationPreferencesCubit, NotificationPreferencesState>(
        listener: (context, state) {
          if (state is NotificationPreferencesUpdating) {
            context.showLoadingOverlay();
          } else {
            context.hideLoadingOverlay();
          }

          if (state is NotificationPreferencesUpdateError) {
            context.showErrorSnackBar(state.message);
          } else if (state is NotificationPreferencesError) {
            context.showErrorSnackBar(state.message);
          }
        },
        child: Scaffold(
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
                        BlocBuilder<
                          NotificationPreferencesCubit,
                          NotificationPreferencesState
                        >(
                          builder: (context, state) {
                            if (state is NotificationPreferencesLoading ||
                                state is NotificationPreferencesInitial) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 80),
                                child: Center(
                                  child: CustomLoadingIndicator(size: 100),
                                ),
                              );
                            }

                            NotificationPreferencesModel? preferences;
                            if (state is NotificationPreferencesLoaded) {
                              preferences = state.preferences;
                            } else if (state
                                is NotificationPreferencesUpdating) {
                              preferences = state.currentPreferences;
                            } else if (state
                                is NotificationPreferencesUpdateSuccess) {
                              preferences = state.preferences;
                            } else if (state
                                is NotificationPreferencesUpdateError) {
                              preferences = state.currentPreferences;
                            }

                            final isMarketingNotif =
                                preferences?.marketingPush ?? false;
                            final isSms = preferences?.marketingSms ?? false;
                            final isEmail =
                                preferences?.marketingEmail ?? false;

                            return Column(
                              children: [
                                ProfileTile(
                                  title: LocaleKeys
                                      .settings_marketing_notification
                                      .tr(),
                                  icon: AppAssets.notification,
                                  hasToggle: true,
                                  toggleValue: isMarketingNotif,
                                  onToggleChanged: (val) {
                                    final updated =
                                        (preferences ??
                                                const NotificationPreferencesModel(
                                                  marketingPush: false,
                                                  marketingSms: false,
                                                  marketingEmail: false,
                                                ))
                                            .copyWith(marketingPush: val);
                                    context
                                        .read<NotificationPreferencesCubit>()
                                        .updateNotificationPreferences(updated);
                                  },
                                ),
                                SizedBox(height: sh(8)),
                                ProfileTile(
                                  title: LocaleKeys.settings_whatsapp_messages
                                      .tr(),
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
                                    final updated =
                                        (preferences ??
                                                const NotificationPreferencesModel(
                                                  marketingPush: false,
                                                  marketingSms: false,
                                                  marketingEmail: false,
                                                ))
                                            .copyWith(marketingSms: val);
                                    context
                                        .read<NotificationPreferencesCubit>()
                                        .updateNotificationPreferences(updated);
                                  },
                                ),
                                SizedBox(height: sh(8)),
                                ProfileTile(
                                  title: LocaleKeys.settings_email_notifications
                                      .tr(),
                                  icon: AppAssets.mail,
                                  hasToggle: true,
                                  toggleValue: isEmail,
                                  onToggleChanged: (val) {
                                    final updated =
                                        (preferences ??
                                                const NotificationPreferencesModel(
                                                  marketingPush: false,
                                                  marketingSms: false,
                                                  marketingEmail: false,
                                                ))
                                            .copyWith(marketingEmail: val);
                                    context
                                        .read<NotificationPreferencesCubit>()
                                        .updateNotificationPreferences(updated);
                                  },
                                ),
                              ],
                            );
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
        ),
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
