import 'dart:ui' as ui;

import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/features/auth/presentation/controllers/auth_cubit/auth_cubit.dart';
import 'package:svg_flutter/svg_flutter.dart';

import '../../../auth/data/repos/auth_repository.dart';
import '../../../../core/config/session/session_state.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/helpers/fetch_user_data_helper.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';

import '../widgets/profile_tile.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_user_info_card.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return BlocProvider(
      create: (context) => locator<AuthCubit>(),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is LogoutLoading || state is ProfileUpdateLoading) {
            context.showLoadingOverlay();
          } else {
            context.hideLoadingOverlay();
          }

          if (state is LogoutSuccess) {
            context.pushNamedAndRemoveUntil(Routes.login);
          } else if (state is ProfileUpdateSuccess) {
            context.showSuccessSnackBar(
              LocaleKeys.snackbar_profile_updated_success.tr(context: context),
            );
            locator<AuthRepository>().getUser();
          } else if (state is ProfileUpdateError) {
            context.showErrorSnackBar(state.message);
          } else if (state is LoginError) {
            context.showErrorSnackBar(state.message);
          }
        },
        child: Builder(
          builder: (context) {
            return ValueListenableBuilder(
              valueListenable: currentUser,
              builder: (context, user, _) {
                final isGuest = user == null;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: sh(48)),
                      // Avatar Placeholder
                      const ProfileAvatar(),
                      SizedBox(height: sh(16)),
                      // Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (FetchUserData.getEmail() != null)
                            SizedBox(width: sw(22)),

                          Text(
                            user?.name ?? FetchUserData.getUserName(),
                            style: AppTextStyles.bold23.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),

                          if (FetchUserData.getEmail() != null) ...[
                            SizedBox(width: sw(4)),

                            SvgPicture.asset(
                              AppAssets.verified,
                              width: sw(18),
                              height: sh(18),
                            ),
                          ],
                        ],
                      ),
                      if (!isGuest) ...[
                        SizedBox(height: sh(8)),
                        // Phone
                        Text(
                          FetchUserData.getPhone().replaceFirst(
                            "+966",
                            "+966 ",
                          ),
                          textDirection: ui.TextDirection.ltr,
                          style: AppTextStyles.regular14.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ] else ...[
                        SizedBox(height: sh(8)),
                      ],
                      SizedBox(height: sh(32)),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: context.colors.background,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(sw(24)),
                            topRight: Radius.circular(sw(24)),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: sw(24),
                          vertical: sh(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProfileUserInfoCard(
                              onTap: () {
                                if (isGuest) {
                                  _promptGuestToLogin(context);
                                } else {
                                  context.pushNamed(Routes.profileData).then((
                                    _,
                                  ) {
                                    if (mounted) setState(() {});
                                  });
                                }
                              },
                            ),
                            SizedBox(height: sh(24)),

                            _buildSectionTitle(
                              LocaleKeys.profile_account_info.tr(
                                context: context,
                              ),
                              context,
                            ),
                            SizedBox(height: sh(8)),
                            ProfileTile(
                              title: FetchUserData.isGuest()
                                  ? LocaleKeys.profile_add_email.tr(
                                      context: context,
                                    )
                                  : (FetchUserData.getEmail() ??
                                        LocaleKeys.profile_add_email.tr(
                                          context: context,
                                        )),
                              icon: AppAssets.mail,
                              isVerified:
                                  !FetchUserData.isGuest() &&
                                  FetchUserData.getEmail() != null,
                              onTap: () {
                                if (isGuest) {
                                  _promptGuestToLogin(context);
                                } else
                                // if (FetchUserData.getEmail() == null)
                                {
                                  context.pushNamed(Routes.addEmail);
                                }
                              },
                            ),

                            if (!isGuest) ...[
                              SizedBox(height: sh(8)),
                              ProfileTile(
                                title: FetchUserData.getPhone().replaceFirst(
                                  "+966",
                                  "+966 ",
                                ),
                                isPhoneNumber: true,
                                icon: AppAssets.phone,
                                isVerified: true,
                              ),
                            ],
                            SizedBox(height: sh(8)),
                            ProfileTile(
                              title: LocaleKeys.profile_my_addresses.tr(
                                context: context,
                              ),
                              icon: AppAssets.location,
                              onTap: () {
                                if (isGuest) {
                                  _promptGuestToLogin(context);
                                } else {
                                  context.pushNamed(Routes.myAddresses);
                                }
                              },
                            ),

                            SizedBox(height: sh(8)),
                            ProfileTile(
                              title: LocaleKeys.profile_my_wallet.tr(context: context),
                              icon: AppAssets.wallet,
                              onTap: () {
                                if (isGuest) {
                                  _promptGuestToLogin(context);
                                } else {
                                  context.pushNamed(Routes.myWallet);
                                }
                              },
                            ),
                            SizedBox(height: sh(8)),

                            ProfileTile(
                              title: LocaleKeys.profile_my_packages.tr(
                                context: context,
                              ),
                              icon: AppAssets.packages,
                              onTap: () {
                                if (isGuest) {
                                  _promptGuestToLogin(context);
                                } else {
                                  context.pushNamed(
                                    Routes.mySubscribedPackages,
                                  );
                                }
                              },
                            ),
                            SizedBox(height: sh(24)),
                            _buildSectionTitle(
                              LocaleKeys.profile_about_app.tr(context: context),
                              context,
                            ),
                            SizedBox(height: sh(8)),
                            ProfileTile(
                              title: LocaleKeys.profile_about_us.tr(
                                context: context,
                              ),
                              icon: AppAssets.aboutUs,
                              onTap: () {
                                context.pushNamed(Routes.aboutUs);
                              },
                            ),
                            SizedBox(height: sh(8)),
                            ProfileTile(
                              title: LocaleKeys.profile_settings.tr(
                                context: context,
                              ),
                              icon: AppAssets.settings,
                              onTap: () {
                                context.pushNamed(Routes.settings);
                              },
                            ),
                            SizedBox(height: sh(8)),
                            ProfileTile(
                              title: LocaleKeys.profile_technical_support.tr(
                                context: context,
                              ),
                              icon: AppAssets.support,
                              onTap: () {
                                context.pushNamed(Routes.support);
                              },
                            ),
                            SizedBox(height: sh(8)),
                            ProfileTile(
                              alreadyColoredIcon: true,
                              title: FetchUserData.isGuest()
                                  ? LocaleKeys.auth_login.tr(context: context)
                                  : LocaleKeys.auth_logout.tr(context: context),
                              icon: FetchUserData.isGuest()
                                  ? AppAssets.login
                                  : AppAssets.logout,
                              textColor: FetchUserData.isGuest()
                                  ? context.colors.success
                                  : context.colors.error,
                              onTap: () {
                                if (isGuest) {
                                  context.read<AuthCubit>().logout();
                                } else {
                                  _logout(context);
                                }
                              },
                            ),

                            SizedBox(height: sh(120)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
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

  void _promptGuestToLogin(BuildContext context) {
    FetchUserData.promptGuestToLogin(context);
  }

  void _logout(BuildContext context) {
    if (currentUser.value == null) {
      context.read<AuthCubit>().logout();
    } else {
      context.showWarningAlert(
        message: LocaleKeys.profile_confirm_logout.tr(context: context),
        primaryButtonText: LocaleKeys.auth_logout.tr(context: context),
        onPrimaryPressed: () {
          context.read<AuthCubit>().logout();
          Navigator.pop(context);
        },
      );
    }
  }
}
