import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:svg_flutter/svg.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import '../../data/models/booking_response_model/booking_response_model.dart';

class BookingDetailsSummaryCard extends StatelessWidget {
  final BookingResponseModel booking;

  const BookingDetailsSummaryCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_booking_summary.tr(),
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                context,
                title: LocaleKeys.bookings_service_name.tr(),
                value: context.isAr
                    ? (booking.packageName?.ar ?? booking.packageName?.en ?? '')
                    : (booking.packageName?.en ??
                          booking.packageName?.ar ??
                          ''),
                icon: AppAssets.document,
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                context,
                title: LocaleKeys.bookings_date_and_time.tr(),
                value: booking.formattedDateTime,
                icon: AppAssets.date,
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                context,
                title: LocaleKeys.bookings_total_amount.tr(),
                value:
                    '${booking.totalAmount.toStringAsFixed(2)} ${booking.currency ?? "SAR"}',
                icon: AppAssets.currency,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String title,
    required String value,
    required String icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                context.colors.contentDisabled,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.regular14.copyWith(
                color: context.colors.contentDisabled,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.contentSecondaryLight,
          ),
        ),
      ],
    );
  }
}
