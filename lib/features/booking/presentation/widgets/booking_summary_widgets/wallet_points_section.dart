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

    // Quote-scoped, so only available once a quote exists — 0 means "no cap to
    // explain yet" and the second line simply does not render.
    final int maxPoints = quote?.maxApplicablePoints ?? 0;
    final int maxDiscountMinor = quote?.discountMinorAtMax ?? 0;

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
                  // The balance is almost never what actually comes off THIS
                  // order — the backend caps a redemption at a share of the
                  // order, so a 2,000-point (200.00 SAR) balance still only
                  // takes 64.80 off an 81.00 wash. Showing the balance alone
                  // reads as a broken discount. State the cap next to it, and
                  // only when it genuinely bites (a cap at or above the balance
                  // is not a limit worth explaining).
                  if (maxPoints > 0 && maxPoints < points) ...[
                    const SizedBox(height: 2),
                    Text(
                      LocaleKeys.bookings_max_applicable_points_format.tr(
                        context: context,
                        args: [
                          NumberFormat('#,###').format(maxPoints),
                          (maxDiscountMinor / 100.0).toStringAsFixed(2),
                        ],
                      ),
                      style: AppTextStyles.regular12.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
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
