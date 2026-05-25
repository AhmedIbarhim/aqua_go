import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/utils/app_assets.dart';

class EmptyBookingsWidget extends StatelessWidget {
  const EmptyBookingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(AppAssets.emptyBookings),
            const SizedBox(height: 24),
            Text(
              context.locale.languageCode == 'ar' ? 'لا توجد حجوزات بعد' : 'No bookings yet',
              style: AppTextStyles.semiBold18.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.locale.languageCode == 'ar'
                  ? 'لم تقم بإجراء أي حجوزات بعد. احجز غسلة لسيارتك الآن!'
                  : 'You haven\'t made any bookings yet. Book a wash for your car now!',
              style: AppTextStyles.regular14.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
