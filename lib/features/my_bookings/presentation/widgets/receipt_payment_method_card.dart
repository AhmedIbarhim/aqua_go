import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/core/enums/payment_method_enum.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';

class ReceiptPaymentMethodCard extends StatelessWidget {
  final BookingResponseModel booking;

  const ReceiptPaymentMethodCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    final bool isSub = booking.isCoveredBySubscription;
    final bool isApplePay =
        !isSub && booking.paymentMethod == PaymentMethod.applePay;

    final paymentMethodText = isSub
        ? LocaleKeys.receipt_subscription_package.tr(context: context)
        : (isApplePay
              ? LocaleKeys.bookings_apple_pay.tr(context: context)
              : LocaleKeys.receipt_credit_card.tr(context: context));

    final paymentMethodIconWidget = isSub
        ? Icon(
            Icons.card_membership_outlined,
            color: context.colors.primary,
            size: sw(20),
          )
        : Container(
            padding: EdgeInsets.symmetric(horizontal: sw(6), vertical: sh(4)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(sw(4)),
              border: Border.all(color: context.colors.borderSecondary),
            ),
            child: Image.asset(
              isApplePay ? AppAssets.applePay : AppAssets.visaPay,
              width: sw(32),
              height: sh(18),
              fit: BoxFit.contain,
            ),
          );

    return Container(
      padding: EdgeInsets.all(sw(16)),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(sw(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            LocaleKeys.receipt_payment_method.tr(context: context),
            style: AppTextStyles.regular12.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                paymentMethodText,
                style: AppTextStyles.medium14.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              SizedBox(width: sw(8)),
              paymentMethodIconWidget,
            ],
          ),
        ],
      ),
    );
  }
}
