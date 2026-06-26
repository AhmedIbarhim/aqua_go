import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/features/layout/presentation/views/main_layout.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/custom_button.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/utils/app_assets.dart';

class EmptyBookingsWidget extends StatelessWidget {
  const EmptyBookingsWidget({
    super.key,
    required this.showBookNowButton,
    required this.hasOnlyUpcoming,
  });

  final bool showBookNowButton;
  final bool hasOnlyUpcoming;

  @override
  Widget build(BuildContext context) {
    final String title;
    final String description;
    if (hasOnlyUpcoming) {
      title = context.locale.languageCode == 'ar'
          ? 'لا توجد حجوزات مكتملة'
          : 'No completed bookings';
      description = context.locale.languageCode == 'ar'
          ? 'ليس لديك بعد حجوزات مكتملة'
          : 'You haven\'t any completed bookings yet.';
    } else {
      title = context.locale.languageCode == 'ar'
          ? 'لا توجد حجوزات حالية'
          : 'No upcoming bookings';
      description = context.locale.languageCode == 'ar'
          ? 'لم تقم بإجراء أي حجوزات بعد. احجز غسلة لسيارتك الآن!'
          : 'You haven\'t made any bookings yet. Book a wash for your car now!';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(AppAssets.emptyBookings),
          const SizedBox(height: 40),

          Text(
            title,
            style: AppTextStyles.semiBold18.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: AppTextStyles.regular14.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          if (showBookNowButton)
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.6,
              child: CustomButton(
                text: context.locale.languageCode == 'ar'
                    ? 'احجز الآن'
                    : 'Book now',
                onPressed: () {
                  context
                      .findAncestorStateOfType<MainLayoutState>()
                      ?.changeIndex(0);
                },
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
