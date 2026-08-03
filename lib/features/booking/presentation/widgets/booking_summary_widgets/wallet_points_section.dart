import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/extentions/context_extentions.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../wallet/data/models/loyalty_balance_model.dart';
import '../../controllers/booking_state.dart';

class WalletPointsSection extends StatelessWidget {
  final BookingState bookingState;
  final LoyaltyBalanceModel? loyaltyBalance;
  final bool isPointsToggled;
  final Function(bool) onPointsToggled;

  const WalletPointsSection({
    super.key,
    required this.bookingState,
    required this.loyaltyBalance,
    required this.isPointsToggled,
    required this.onPointsToggled,
  });

  @override
  Widget build(BuildContext context) {
    final quote = bookingState.quote;
    final int balanceValueMinor =
        quote?.currentBalanceValueMinor ??
        loyaltyBalance?.estimatedValueMinor ??
        0;
    final bool isInsufficient = isPointsToggled && (balanceValueMinor < 100);

    final int points =
        quote?.currentBalancePoints ?? loyaltyBalance?.points ?? 0;
    final double pointsValue = balanceValueMinor / 100.0;

    final borderBorder = Border.all(
      color: isPointsToggled
          ? (isInsufficient ? context.colors.error : context.colors.primary)
          : context.colors.borderSecondary.withValues(alpha: 0.3),
      width: 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_wallet_points_title.tr(context: context),
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.themeColor,
            borderRadius: BorderRadius.circular(12),
            border: borderBorder,
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.bookings_pay_using_points.tr(context: context),
                    style: AppTextStyles.medium14.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    LocaleKeys.bookings_available_points_format.tr(
                      context: context,
                      args: [
                        NumberFormat('#,###').format(points),
                        pointsValue.toStringAsFixed(2),
                      ],
                    ),
                    style: AppTextStyles.regular12.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Switch.adaptive(
                value: isPointsToggled,
                onChanged: onPointsToggled,
                activeThumbColor: isInsufficient
                    ? context.colors.errorSecondary
                    : context.colors.primary,
                activeTrackColor:
                    (isInsufficient
                            ? context.colors.errorSecondary
                            : context.colors.primary)
                        .withValues(alpha: 0.3),
                inactiveThumbColor: context.colors.textTertiary,
                inactiveTrackColor: context.colors.defaultSubtle,
              ),
            ],
          ),
        ),
        if (isInsufficient) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              LocaleKeys.bookings_insufficient_points.tr(context: context),
              style: AppTextStyles.regular12.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
