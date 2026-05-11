import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../generated/locale_keys.g.dart';

class ProfileTile extends StatelessWidget {
  final String title;
  final String icon;
  final Color? textColor;
  final Color? borderColor;
  final bool isVerified;
  final bool hasToggle;
  final bool toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final VoidCallback? onTap;

  const ProfileTile({
    super.key,
    required this.title,
    required this.icon,
    this.textColor,
    this.borderColor,
    this.isVerified = false,
    this.hasToggle = false,
    this.toggleValue = false,
    this.onToggleChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    double sw(double width) => (width / 414) * screenWidth;
    double sh(double height) => (height / 896) * screenHeight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: sw(16), vertical: sh(12)),
        decoration: BoxDecoration(
          color: context.colors.cardBackGround,
          border: Border.all(
            color: borderColor ?? context.colors.borderSecondary,
          ),
          borderRadius: BorderRadius.circular(sw(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  SvgPicture.asset(icon, width: sw(24), height: sw(24)),
                  SizedBox(width: sw(8)),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.regular14.copyWith(
                        color: textColor ?? context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isVerified)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw(8),
                  vertical: sh(4),
                ),
                decoration: BoxDecoration(
                  color: context.colors.success.withAlpha(25),
                  borderRadius: BorderRadius.circular(sw(16)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      LocaleKeys.profile_verified.tr(),
                      style: AppTextStyles.regular12.copyWith(
                        color: context.colors.success,
                      ),
                    ),
                    SizedBox(width: sw(4)),
                    Icon(
                      Icons.check_circle,
                      color: context.colors.success,
                      size: sw(16),
                    ),
                  ],
                ),
              ),
            if (hasToggle)
              SizedBox(
                height: sh(24),
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
