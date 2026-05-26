import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import '../../data/models/booking_response_model.dart';

class BookingDetailsNumberCard extends StatelessWidget {
  final BookingResponseModel booking;

  const BookingDetailsNumberCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    String statusText = context.locale.languageCode == 'ar'
        ? 'قيد الانتظار'
        : 'Pending';
    Color statusBg = context.colors.warning;
    Color statusTextColor = Colors.black;

    if (booking.status != null) {
      switch (booking.status!) {
        case BookingStatus.UNSCHEDULED:
          statusText = context.locale.languageCode == 'ar'
              ? 'غير مجدول'
              : 'Unscheduled';
          statusBg = Colors.grey.shade400;
          statusTextColor = Colors.white;
          break;
        case BookingStatus.PENDING:
          statusText = context.locale.languageCode == 'ar'
              ? 'قيد الانتظار'
              : 'Pending';
          statusBg = Colors.orange;
          statusTextColor = Colors.white;
          break;
        case BookingStatus.ASSIGNED:
          statusText = context.locale.languageCode == 'ar'
              ? 'تم تعيين السائق'
              : 'Biker Assigned';
          statusBg = Colors.teal;
          statusTextColor = Colors.white;
          break;
        case BookingStatus.ON_THE_WAY:
          statusText = context.locale.languageCode == 'ar'
              ? 'في الطريق'
              : 'On the Way';
          statusBg = Colors.blueAccent;
          statusTextColor = Colors.white;
          break;
        case BookingStatus.ARRIVED:
          statusText = context.locale.languageCode == 'ar'
              ? 'وصل السائق'
              : 'Biker Arrived';
          statusBg = Colors.purple;
          statusTextColor = Colors.white;
          break;
        case BookingStatus.STARTED:
          statusText = context.locale.languageCode == 'ar'
              ? 'بدأ الغسيل'
              : 'Washing Started';
          statusBg = Colors.blue;
          statusTextColor = Colors.white;
          break;
        case BookingStatus.COMPLETED:
          statusText = context.locale.languageCode == 'ar'
              ? 'مكتمل'
              : 'Completed';
          statusBg = Colors.green;
          statusTextColor = Colors.white;
          break;
        case BookingStatus.CANCELLED:
          statusText = context.locale.languageCode == 'ar'
              ? 'ملغي'
              : 'Cancelled';
          statusBg = Colors.red;
          statusTextColor = Colors.white;
          break;
      }
    }

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
                '#${booking.id!.substring(0, 5)}',
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
