import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.screenBG,
          borderRadius: BorderRadius.circular(100),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(
              index: 0,
              label: LocaleKeys.layout_home.tr(),
              iconEnabled: AppAssets.homeEnabled,
              iconDisabled: AppAssets.homeDisabled,
            ),
            _buildNavItem(
              index: 1,
              label: LocaleKeys.layout_my_cars.tr(),
              iconEnabled: AppAssets.myCarsEnabled,
              iconDisabled: AppAssets.myCarsDisabled,
            ),
            _buildNavItem(
              index: 2,
              label: LocaleKeys.layout_reservations.tr(),
              iconEnabled: AppAssets.reservationsEnabled,
              iconDisabled: AppAssets.reservationsDisabled,
            ),
            _buildNavItem(
              index: 3,
              label: LocaleKeys.layout_profile.tr(),
              iconEnabled: AppAssets.accountEnabled,
              iconDisabled: AppAssets.accountDisabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required String iconEnabled,
    required String iconDisabled,
  }) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isActive ? iconEnabled : iconDisabled,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isActive ? AppColors.primary : AppColors.contentDisabled,
                BlendMode.srcIn,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.regular14.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
