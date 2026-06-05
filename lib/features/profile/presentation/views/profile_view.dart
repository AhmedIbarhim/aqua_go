import 'dart:ui' as ui;

import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/features/auth/controllers/auth_cubit/auth_cubit.dart';

import '../../../rating/presentation/widgets/rating_widget.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/helpers/fetch_user_data_helper.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/image_picker_helper.dart';

import '../widgets/profile_tile.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

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
              LocaleKeys.snackbar_profile_updated_success.tr(),
            );
          } else if (state is ProfileUpdateError) {
            context.showErrorSnackBar(state.message);
          } else if (state is LoginError) {
            context.showErrorSnackBar(state.message);
          }
        },
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: sh(48)),
                  // Avatar Placeholder
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return GestureDetector(
                        onTap: () async {
                          if (FetchUserData.isGuest()) {
                            _promptGuestToLogin(context);
                          } else {
                            final file =
                                await ImagePickerHelper.showImageSourceDialog(
                                  context,
                                );
                            if (file != null && context.mounted) {
                              context.read<AuthCubit>().uploadAvatar(file.path);
                            }
                          }
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: sw(134),
                              height: sw(134),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.colors.primary,
                                border: Border.all(
                                  color: context.colors.primary,
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: FetchUserData.getAvatarUrl() != null
                                    ? CachedNetworkImage(
                                        imageUrl: FetchUserData.getAvatarUrl()!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                              Icons.person,
                                              size: sw(80),
                                              color: context.colors.background,
                                            ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: sw(80),
                                        color: context.colors.background,
                                      ),
                              ),
                            ),
                            if (!FetchUserData.isGuest())
                              Positioned(
                                right: sw(4),
                                bottom: sw(4),
                                child: Container(
                                  padding: EdgeInsets.all(sw(6)),
                                  decoration: BoxDecoration(
                                    color: context.colors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: context.colors.background,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: sw(16),
                                    color: context.colors.background,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: sh(16)),
                  // Name
                  Text(
                    FetchUserData.getUserName(),
                    style: AppTextStyles.bold23.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (!FetchUserData.isGuest()) ...[
                    SizedBox(height: sh(8)),
                    // Phone
                    Text(
                      FetchUserData.getPhone().replaceFirst("+966", "+966 "),
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
                        _buildUserInfoCard(context, sw, sh),
                        SizedBox(height: sh(24)),

                        _buildSectionTitle(
                          LocaleKeys.profile_account_info.tr(),
                          context,
                        ),
                        SizedBox(height: sh(8)),
                        ProfileTile(
                          title: FetchUserData.isGuest()
                              ? LocaleKeys.profile_add_email.tr()
                              : (FetchUserData.getEmail() ??
                                    LocaleKeys.profile_add_email.tr()),
                          icon: AppAssets.mail,
                          isVerified:
                              !FetchUserData.isGuest() &&
                              FetchUserData.getEmail() != null,
                          onTap: () {
                            if (FetchUserData.isGuest()) {
                              _promptGuestToLogin(context);
                            } else if (FetchUserData.getEmail() == null) {
                              context.pushNamed(Routes.addEmail);
                            }
                          },
                        ),

                        if (!FetchUserData.isGuest()) ...[
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
                          title: LocaleKeys.profile_my_addresses.tr(),
                          icon: AppAssets.location,
                          onTap: () {
                            if (FetchUserData.isGuest()) {
                              _promptGuestToLogin(context);
                            } else {
                              context.pushNamed(Routes.myAddresses);
                            }
                          },
                        ),
                        SizedBox(height: sh(8)),
                        ProfileTile(
                          title: LocaleKeys.profile_my_wallet.tr(),
                          icon: AppAssets.wallet,
                          onTap: () {
                            if (FetchUserData.isGuest()) {
                              _promptGuestToLogin(context);
                            }
                          },
                        ),

                        SizedBox(height: sh(8)),

                        ProfileTile(
                          title: LocaleKeys.profile_my_packages.tr(),
                          icon: AppAssets.packages,
                          onTap: () {
                            if (FetchUserData.isGuest()) {
                              _promptGuestToLogin(context);
                            }
                          },
                        ),
                        SizedBox(height: sh(24)),
                        _buildSectionTitle(
                          LocaleKeys.profile_about_app.tr(),
                          context,
                        ),
                        SizedBox(height: sh(8)),
                        ProfileTile(
                          title: LocaleKeys.profile_about_us.tr(),
                          icon: AppAssets.aboutUs,
                          onTap: () {
                            context.pushNamed(Routes.aboutUs);
                          },
                        ),
                        SizedBox(height: sh(8)),
                        ProfileTile(
                          title: LocaleKeys.profile_settings.tr(),
                          icon: AppAssets.settings,
                          onTap: () {
                            context.pushNamed(Routes.settings);
                          },
                        ),
                        SizedBox(height: sh(8)),
                        ProfileTile(
                          title: LocaleKeys.profile_technical_support.tr(),
                          icon: AppAssets.support,
                          onTap: () {
                            context.pushNamed(Routes.support);
                          },
                        ),
                        SizedBox(height: sh(8)),
                        ProfileTile(
                          alreadyColoredIcon: true,
                          title: FetchUserData.isGuest()
                              ? LocaleKeys.auth_login.tr()
                              : LocaleKeys.auth_logout.tr(),
                          icon: FetchUserData.isGuest()
                              ? AppAssets.login
                              : AppAssets.logout,
                          textColor: FetchUserData.isGuest()
                              ? context.colors.success
                              : context.colors.error,
                          onTap: () {
                            if (FetchUserData.isGuest()) {
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
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(
    BuildContext context,
    double Function(double) sw,
    double Function(double) sh,
  ) {
    return GestureDetector(
      onTap: () {
        if (FetchUserData.isGuest()) {
          _promptGuestToLogin(context);
        } else {
          context.pushNamed(Routes.profileData);
        }
      },
      child: Container(
        padding: EdgeInsets.all(sw(12)),
        decoration: BoxDecoration(
          color: context.colors.cardBackGround,
          border: Border.all(color: context.colors.borderSecondary),
          borderRadius: BorderRadius.circular(sw(12)),
        ),
        child: Row(
          children: [
            Container(
              width: sw(40),
              height: sw(40),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(sw(8)),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.personDisabled,
                  width: sw(20),
                  height: sw(20),
                  colorFilter: ColorFilter.mode(
                    context.colors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(width: sw(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FetchUserData.getUserName(),
                    style: AppTextStyles.regular14.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      RatingWidget(rating: FetchUserData.getUserRating()),
                      SizedBox(width: sw(4)),
                      Text(
                        FetchUserData.isGuest()
                            ? ""
                            : FetchUserData.getUserRating() == 0
                            ? ""
                            : '(${FetchUserData.getUserRating()})',
                        style: AppTextStyles.regular12.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
    if (FetchUserData.isGuest()) {
      context.read<AuthCubit>().logout();
    } else {
      context.showWarningAlert(
        message: LocaleKeys.profile_confirm_logout.tr(),
        primaryButtonText: LocaleKeys.auth_logout.tr(),
        onPrimaryPressed: () {
          context.read<AuthCubit>().logout();
          Navigator.pop(context);
        },
      );
    }
  }
}
