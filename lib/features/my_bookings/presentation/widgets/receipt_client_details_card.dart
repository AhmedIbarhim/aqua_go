import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'receipt_info_row.dart';

class ReceiptClientDetailsCard extends StatelessWidget {
  final BookingResponseModel booking;

  const ReceiptClientDetailsCard({super.key, required this.booking});

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
            LocaleKeys.receipt_customer_details.tr(context: context),
            style: AppTextStyles.regular12.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: sh(14)),
          ReceiptInfoRow(
            label: LocaleKeys.receipt_client_name.tr(context: context),
            value: booking.customerName ?? '',
          ),
          SizedBox(height: sh(12)),
          ReceiptInfoRow(
            label: LocaleKeys.receipt_car_location.tr(context: context),
            value: booking.location,
          ),
        ],
      ),
    );
  }
}
