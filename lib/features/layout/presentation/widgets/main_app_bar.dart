import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    // Scaling helpers
    double sw(double width) => (width / 414) * screenWidth;
    double sh(double height) => (height / 896) * screenHeight;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw(16), vertical: sh(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Right Side: Greeting and Avatar
            Row(
              children: [
                Container(
                  width: sw(40),
                  height: sw(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.primary, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(sw(20)),
                    child: Image.network(
                      'https://ui-avatars.com/api/?name=Mohamed+Faisal&background=00D5DD&color=fff',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: sw(8)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${LocaleKeys.layout_welcome.tr()} محمد فيصل,',
                      style: AppTextStyles.regular12.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          LocaleKeys.layout_ready_to_serve.tr(),
                          style: AppTextStyles.medium14,
                        ),
                        SizedBox(width: sw(4)),
                        Image.asset(
                          AppAssets.wavingHand,
                          width: sw(16),
                          height: sw(16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // Left Side: Gift and Notifications
            Row(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.pushNamed(Routes.notification);
                      },
                      child: Container(
                        padding: EdgeInsets.all(sw(8)),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(sw(8)),
                        ),
                        child: SvgPicture.asset(
                          AppAssets.notification,
                          width: sw(24),
                          height: sw(24),
                          placeholderBuilder: (context) =>
                              SizedBox(width: sw(24), height: sw(24)),
                          colorFilter: ColorFilter.mode(
                            context.colors.textPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: context.isEn ? sw(8) : null,
                      right: context.isAr ? sw(8) : null,
                      top: sw(8),
                      child: Container(
                        width: sw(10),
                        height: sw(10),
                        decoration: BoxDecoration(
                          color: context.colors.warning,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.colors.screenBG,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: sw(8)),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(sw(8)),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(sw(8)),
                    ),
                    child: SvgPicture.asset(
                      AppAssets.gift,
                      width: sw(24),
                      height: sw(24),
                      placeholderBuilder: (context) =>
                          SizedBox(width: sw(24), height: sw(24)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
