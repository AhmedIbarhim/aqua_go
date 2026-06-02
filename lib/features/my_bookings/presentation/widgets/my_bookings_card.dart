import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../data/models/booking_summary_model.dart';
import '../views/my_booking_deatails_view.dart';

class MyBookingsCard extends StatelessWidget {
  final BookingSummaryModel booking;

  const MyBookingsCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.themeColor,
        border: Border.all(color: context.colors.borderSecondary),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  booking.title,
                  style: AppTextStyles.medium16,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              if (booking.isUpcoming)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.warning,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    LocaleKeys.bookings_upcoming.tr(),
                    style: AppTextStyles.regular12.copyWith(
                      color: context.colors.screenBG,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Details Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                LocaleKeys.bookings_booking_details.tr(),
                style: AppTextStyles.medium12.copyWith(height: 16 / 12),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.cardBackGround,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Location
                    _buildDetailRow(
                      context: context,
                      title: LocaleKeys.bookings_car_location.tr(),
                      value: booking.location,
                      iconPath: AppAssets.location,
                    ),
                    const SizedBox(height: 12),
                    // Date & Time
                    _buildDetailRow(
                      context: context,
                      title: LocaleKeys.bookings_date_and_time.tr(),
                      value: booking.formattedDateTime,
                      iconPath: AppAssets.calender,
                    ),
                    const SizedBox(height: 12),
                    // Total Amount
                    _buildDetailRow(
                      context: context,
                      title: LocaleKeys.bookings_total_amount.tr(),
                      value: booking.totalAmount.toStringAsFixed(2),
                      iconPath: AppAssets.money,
                      isAmount: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Actions
          GestureDetector(
            onTap: () {
              context.pushNamed(
                Routes.myBookingDetails,
                arguments: MyBookingDetailsArgs(booking: booking),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.themeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.bookings_view_details.tr(),
                    style: AppTextStyles.medium14.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward, // Points left in RTL
                    color: context.colors.primary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required String title,
    required String value,
    required String iconPath,
    bool isAmount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                context.colors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.regular12.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        // Value
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: AppTextStyles.regular12.copyWith(
                    color: context.colors.contentSecondaryLight,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // textDirection: TextDirection.ltr,
                ),
              ),
              if (isAmount) ...[
                const SizedBox(width: 4),
                SvgPicture.asset(
                  AppAssets.currency,
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(
                    context.colors.contentSecondaryLight,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
