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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Right Side: Greeting and Avatar
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.primary, width: 1),
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      'https://ui-avatars.com/api/?name=Mohamed+Faisal&background=00D5DD&color=fff',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                        const SizedBox(width: 4),
                        Image.asset(
                          AppAssets.wavingHand,
                          width: 16,
                          height: 16,
                          // errorBuilder: (context, error, stackTrace) =>
                          //     const SizedBox(width: 16, height: 16),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          AppAssets.notification,
                          width: 24,
                          height: 24,
                          placeholderBuilder: (context) =>
                              const SizedBox(width: 24, height: 24),
                          colorFilter: ColorFilter.mode(
                            context.colors.textPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: context.isEn ? 8 : null,
                      right: context.isAr ? 8 : null,
                      top: 8,
                      child: Container(
                        width: 10,
                        height: 10,
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
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset(
                      AppAssets.gift,
                      width: 24,
                      height: 24,
                      placeholderBuilder: (context) =>
                          const SizedBox(width: 24, height: 24),
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
