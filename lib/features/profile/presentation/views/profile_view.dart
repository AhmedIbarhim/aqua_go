import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/rating_widget.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';

import '../widgets/profile_tile.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    // Scaling helpers
    double sw(double width) => (width / 414) * screenWidth;
    double sh(double height) => (height / 896) * screenHeight;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: sh(48)),
          // Avatar Placeholder
          Container(
            width: sw(134),
            height: sw(134),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.primary,
            ),
            child: Icon(
              Icons.person,
              size: sw(80),
              color: context.colors.background,
            ),
          ),
          SizedBox(height: sh(16)),
          // Name
          Text(
            'فيصل محمد',
            style: AppTextStyles.bold23.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: sh(8)),
          // Phone
          Text(
            '+966 123333478',
            style: AppTextStyles.regular14.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
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
            padding: EdgeInsets.symmetric(horizontal: sw(24), vertical: sh(24)),
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
                  title: LocaleKeys.profile_add_email.tr(),
                  icon: AppAssets.mail,
                  onTap: () {
                    context.pushNamed(Routes.addEmail);
                  },
                ),
                SizedBox(height: sh(8)),
                ProfileTile(
                  title: '+966 123445598',
                  icon: AppAssets.phone,
                  isVerified: true,
                ),
                SizedBox(height: sh(8)),
                ProfileTile(
                  title: LocaleKeys.profile_my_addresses.tr(),
                  icon: AppAssets.location,
                  onTap: () {
                    context.pushNamed(Routes.myAddresses);
                  },
                ),
                SizedBox(height: sh(8)),
                ProfileTile(
                  title: LocaleKeys.profile_my_wallet.tr(),
                  icon: AppAssets.wallet,
                ),

                SizedBox(height: sh(8)),

                ProfileTile(
                  title: LocaleKeys.profile_my_packages.tr(),
                  icon: AppAssets.packages,
                ),
                SizedBox(height: sh(24)),
                _buildSectionTitle(LocaleKeys.profile_about_app.tr(), context),
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
                  title: LocaleKeys.auth_logout.tr(),
                  icon: AppAssets.logout,
                  textColor: context.colors.error,
                ),

                SizedBox(height: sh(120)),
              ],
            ),
          ),
        ],
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
        context.pushNamed(Routes.profileData);
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
                    'فيصل محمد',
                    style: AppTextStyles.regular14.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      RatingWidget(rating: 4.5),
                      SizedBox(width: sw(4)),
                      Text(
                        '(4.5)',
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
}
