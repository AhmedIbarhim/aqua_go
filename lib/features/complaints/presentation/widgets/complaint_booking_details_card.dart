import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';

class ComplaintBookingDetailsCard extends StatelessWidget {
  final String bookingId;
  final BookingResponseModel? booking;

  const ComplaintBookingDetailsCard({
    super.key,
    required this.bookingId,
    this.booking,
  });

  @override
  Widget build(BuildContext context) {
    double sw(double width) => (width / 414) * MediaQuery.sizeOf(context).width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_booking_details.tr(),
          style: AppTextStyles.regular16,
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(sw(12)),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildDetailRow(
                context: context,
                title: LocaleKeys.bookings_booking_number.tr(),
                value: '#${booking?.id ?? bookingId}',
                icon: AppAssets.note,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                context: context,
                title: LocaleKeys.bookings_service_name.tr(),
                value: booking?.title ?? '',
                icon: AppAssets.document,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                context: context,
                title: LocaleKeys.bookings_car_plate.tr(),
                value: booking?.plateMasked ?? '',
                icon: AppAssets.boardNum,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                context: context,
                title: LocaleKeys.bookings_date_and_time.tr(),
                value: booking?.formattedDateTime ?? '',
                icon: AppAssets.date,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                context: context,
                title: LocaleKeys.bookings_worker_name.tr(),
                value: booking?.assignedWorker?.displayName ?? '',
                icon: AppAssets.personDisabled,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required String title,
    required String value,
    required dynamic icon,
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
        Text(
          value,
          style: AppTextStyles.regular12.copyWith(
            color: context.colors.contentSecondaryLight,
          ),
        ),
      ],
    );
  }
}
