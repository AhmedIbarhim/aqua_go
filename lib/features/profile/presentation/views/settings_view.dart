import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:aqua_go/core/components/custom_radio_widget.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/config/controllers/language_controller/language_cubit.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/config/controllers/theme_controller/theme_cubit.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../../core/config/session/session_state.dart';
import '../../../../core/route/routes.dart';
import '../../data/models/notification_preferences_model.dart';
import '../controllers/notification_preferences_cubit/notification_preferences_cubit.dart';
import '../widgets/profile_tile.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // Backed by the reactive notifier so a login-while-open transition is reflected.
  bool get isGuest => currentUser.value == null;

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return ValueListenableBuilder(
      valueListenable: currentUser,
      builder: (context, user, _) => BlocProvider(
        create: (context) {
          final cubit = locator<NotificationPreferencesCubit>();
          if (!isGuest) {
            cubit.getNotificationPreferences();
          }
          return cubit;
        },
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
            appBar: GenericAppBar(
              title: LocaleKeys.profile_settings.tr(context: context),
            ),
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
                            LocaleKeys.settings_more_settings.tr(
                              context: context,
                            ),
                            context,
                          ),
                          SizedBox(height: sh(8)),
                          ProfileTile(
                            title: LocaleKeys.settings_language.tr(
                              context: context,
                            ),
                            icon: AppAssets.language,
                            onTap: () {
                              // context.pushNamed(Routes.languageSelect);
                              _showLanguageSelectionDialog(context);
                            },
                          ),
                          SizedBox(height: sh(8)),
                          ProfileTile(
                            title: LocaleKeys.settings_privacy_policy.tr(
                              context: context,
                            ),
                            icon: AppAssets.privacy,
                            onTap: () {
                              context.pushNamed(Routes.privacyPolicy);
                            },
                          ),
                          SizedBox(height: sh(8)),
                          ProfileTile(
                            title: LocaleKeys.settings_terms_and_conditions.tr(
                              context: context,
                            ),
                            icon: AppAssets.terms,
                            onTap: () {
                              context.pushNamed(Routes.termsAndConditions);
                            },
                          ),
                          SizedBox(height: sh(8)),
                          BlocBuilder<ThemeCubit, ThemeState>(
                            builder: (context, themeState) {
                              final isDarkMode =
                                  themeState.themeMode == ThemeMode.dark;
                              return ProfileTile(
                                title: LocaleKeys.settings_dark_mode.tr(
                                  context: context,
                                ),
                                icon: AppAssets.darkMode,
                                hasToggle: true,
                                toggleValue: isDarkMode,
                                onToggleChanged: (val) {
                                  context.read<ThemeCubit>().toggleTheme(val);
                                },
                              );
                            },
                          ),
                          if (!isGuest) ...[
                            SizedBox(height: sh(24)),
                            _buildSectionTitle(
                              LocaleKeys.settings_get_notifications.tr(
                                context: context,
                              ),
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
                                  return SizedBox(
                                    height: sh(300),
                                    child: Center(
                                      child: CustomLoadingIndicator(size: 70),
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
                                final isSms =
                                    preferences?.marketingSms ?? false;
                                final isEmail =
                                    preferences?.marketingEmail ?? false;

                                return Column(
                                  children: [
                                    ProfileTile(
                                      title: LocaleKeys
                                          .settings_marketing_notification
                                          .tr(context: context),
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
                                            .read<
                                              NotificationPreferencesCubit
                                            >()
                                            .updateNotificationPreferences(
                                              updated,
                                            );
                                      },
                                    ),
                                    // SizedBox(height: sh(8)),
                                    // ProfileTile(
                                    //   title: LocaleKeys.settings_whatsapp_messages
                                    //       .tr(context: context),
                                    //   icon: AppAssets.whatsppOutlined,
                                    //   hasToggle: true,
                                    //   toggleValue: isWhatsapp,
                                    //   onToggleChanged: (val) {
                                    //     setState(() {
                                    //       isWhatsapp = val;
                                    //     });
                                    //   },
                                    // ),
                                    SizedBox(height: sh(8)),
                                    ProfileTile(
                                      title: LocaleKeys.settings_sms_messages
                                          .tr(context: context),
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
                                            .read<
                                              NotificationPreferencesCubit
                                            >()
                                            .updateNotificationPreferences(
                                              updated,
                                            );
                                      },
                                    ),
                                    SizedBox(height: sh(8)),
                                    ProfileTile(
                                      title: LocaleKeys
                                          .settings_email_notifications
                                          .tr(context: context),
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
                                            .read<
                                              NotificationPreferencesCubit
                                            >()
                                            .updateNotificationPreferences(
                                              updated,
                                            );
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

  void _showLanguageSelectionDialog(BuildContext context) {
    context.showCustomAlert(
      child: BlocConsumer<LanguageCubit, LanguageState>(
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
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final currentLocale = state.locale;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.settings_language.tr(context: context),
                style: AppTextStyles.medium16.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _DialogLanguageItem(
                title: 'العربية',
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
              _DialogLanguageItem(
                title: 'English',
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
          );
        },
      ),
    );
  }
}

class _DialogLanguageItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _DialogLanguageItem({
    required this.title,
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
                AppAssets.locale,
                width: 24,
                height: 16,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? context.colors.primary
                      : context.colors.textSecondary,
                  BlendMode.srcIn,
                ),
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
