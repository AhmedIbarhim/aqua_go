import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors_extension.dart';

class MyBookingsTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const MyBookingsTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? context.colors.defaultSubtle
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selectedIndex == 0
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF2D3439,
                            ).withValues(alpha: 0.04),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  LocaleKeys.bookings_current_bookings.tr(),
                  style: selectedIndex == 0
                      ? AppTextStyles.medium14
                      : AppTextStyles.regular14.copyWith(
                          color: context.colors.contentDisabled,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? context.colors.defaultSubtle
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selectedIndex == 1
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF2D3439,
                            ).withValues(alpha: 0.04),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  LocaleKeys.bookings_previous_bookings.tr(),
                  style: selectedIndex == 1
                      ? AppTextStyles.medium14
                      : AppTextStyles.regular14.copyWith(
                          color: context.colors.contentDisabled,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
