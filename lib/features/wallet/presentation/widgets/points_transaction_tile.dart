import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import '../../data/models/points_transaction_model.dart';

class PointsTransactionTile extends StatelessWidget {
  final PointsTransactionModel transaction;

  const PointsTransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    final locale = context.locale.toString();
    final dateFormatted = DateFormat(
      'd MMMM yyyy',
      locale,
    ).format(transaction.date);
    final timeFormatted = DateFormat(
      'hh:mm a',
      locale,
    ).format(transaction.date).replaceAll('AM', 'AM').replaceAll('PM', 'PM');

    final isEarned = transaction.isEarned;
    final pointsColor = isEarned
        ? context.colors.success
        : context.colors.errorSecondary;
    final sign = isEarned ? '+' : '-';

    final pointsText = '$sign${transaction.points} ';

    return Container(
      margin: EdgeInsets.only(bottom: sh(12)),
      padding: EdgeInsets.symmetric(horizontal: sw(16), vertical: sh(16)),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(sw(12)),
        border: Border.all(color: context.colors.defaultSubtle, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: sw(40),
            height: sw(40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.screenBG,
              border: Border.all(
                color: pointsColor.withAlpha((0.3 * 255).round()),
                width: 1.5,
              ),
            ),
            child: Icon(
              isEarned ? Icons.arrow_upward : Icons.arrow_downward,
              color: pointsColor,
              size: sw(20),
            ),
          ),
          SizedBox(width: sw(16)),
          // Middle: Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.kind == "ADMIN_CREDIT"
                      ? LocaleKeys.wallet_admin_credit.tr(context: context)
                      : transaction.refType == "booking"
                      ? LocaleKeys.wallet_booking_number.tr(
                          context: context,
                          args: [transaction.refNumber!],
                        )
                      : transaction.refType == "gift"
                      ? LocaleKeys.wallet_gift_number.tr(
                          context: context,
                          args: [transaction.refNumber!],
                        )
                      : "",
                  style: AppTextStyles.bold13.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: sh(4)),
                Text(
                  '$dateFormatted | $timeFormatted',
                  style: AppTextStyles.regular12.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: sw(12)),
          Row(
            children: [
              Text(
                pointsText,
                style: AppTextStyles.bold16.copyWith(color: pointsColor),
              ),
              Text(
                LocaleKeys.wallet_points.tr(context: context),
                style: AppTextStyles.regular12.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
