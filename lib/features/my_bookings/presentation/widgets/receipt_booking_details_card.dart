import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'receipt_info_row.dart';

class ReceiptBookingDetailsCard extends StatelessWidget {
  final BookingResponseModel booking;

  const ReceiptBookingDetailsCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return Container(
      padding: EdgeInsets.all(sw(16)),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(sw(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.receipt_booking_details.tr(context: context),
            style: AppTextStyles.regular12.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: sh(14)),
          ReceiptInfoRow(
            label: LocaleKeys.receipt_service_name.tr(context: context),
            value: booking.title,
          ),
          SizedBox(height: sh(12)),
          ReceiptInfoRow(
            label: LocaleKeys.receipt_booking_date_time.tr(context: context),
            value: _getFormattedDateTime(context),
          ),
        ],
      ),
    );
  }

  String _getFormattedDateTime(BuildContext context) {
    if (booking.scheduledAt == null) return '';
    try {
      final time = DateTime.parse(booking.scheduledAt!).toLocal();
      final dateStr = DateFormat('yyyy/MM/dd').format(time);

      final hour = time.hour;
      final minute = time.minute;
      final minStr = minute.toString().padLeft(2, '0');

      String period;
      int displayHour = hour;
      if (context.isAr) {
        if (hour >= 12) {
          period = hour == 12 ? 'ظهراً' : 'مساءً';
          if (hour > 12) displayHour = hour - 12;
        } else {
          period = 'صباحاً';
          if (hour == 0) displayHour = 12;
        }
        return '$displayHour:$minStr $period . $dateStr';
      } else {
        final timeStr = DateFormat('h:mm a').format(time);
        return '$timeStr . $dateStr';
      }
    } catch (_) {
      return booking.formattedDateTime;
    }
  }
}
