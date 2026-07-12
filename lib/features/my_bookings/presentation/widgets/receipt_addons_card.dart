import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';

class ReceiptAddonsCard extends StatelessWidget {
  final BookingResponseModel booking;

  const ReceiptAddonsCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    if (booking.addOns == null || booking.addOns!.isEmpty) {
      return const SizedBox.shrink();
    }

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
            LocaleKeys.receipt_booking_addons.tr(context: context),
            style: AppTextStyles.regular12.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: sh(14)),
          ...booking.addOns!.map((addon) {
            return Padding(
              padding: EdgeInsets.only(bottom: sh(8)),
              child: Text(
                '${addon.qty ?? 1} ${addon.name}',
                style: AppTextStyles.medium14.copyWith(
                  color: context.colors.textPrimary,
                ),
                textAlign: TextAlign.end,
              ),
            );
          }),
        ],
      ),
    );
  }
}
