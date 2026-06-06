import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import '../../data/models/booking_response_model/booking_response_model.dart';

class BookingDetailsNumberCard extends StatelessWidget {
  final BookingResponseModel booking;

  const BookingDetailsNumberCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = booking.status;
    final statusText =
        status?.getStatusText(context) ??
        (context.isAr ? 'قيد الانتظار' : 'Pending');
    final statusBg = status?.getStatusBg(context) ?? context.colors.warning;
    final statusTextColor = status?.getStatusTextColor(context) ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_booking_number.tr(),
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${booking.referenceNumber}',
                style: AppTextStyles.regular14.copyWith(
                  color: context.colors.contentSecondaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.regular12.copyWith(
                    color: statusTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
