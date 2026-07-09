import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../data/models/gift_model.dart';

class ReceivedGiftCard extends StatelessWidget {
  final GiftModel gift;
  final VoidCallback onRedeemPressed;

  const ReceivedGiftCard({
    super.key,
    required this.gift,
    required this.onRedeemPressed,
  });

  @override
  Widget build(BuildContext context) {
    IconData getThemeIcon(String? iconName) {
      switch (iconName?.toLowerCase()) {
        case 'cake':
          return Icons.cake_outlined;
        case 'gift':
          return Icons.card_giftcard_outlined;
        case 'trophy':
          return Icons.emoji_events_outlined;
        default:
          return Icons.card_giftcard_outlined;
      }
    }

    // Button is shown if the gift is active/unused (ISSUED or DELIVERED)
    final bool showRedeemButton =
        gift.status == GiftStatus.ISSUED || gift.status == GiftStatus.DELIVERED;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.themeColor,
        border: Border.all(color: context.colors.borderSecondary),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge
              if (gift.status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: gift.status!.getStatusBg(context),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    gift.status!.getStatusText(context),
                    style: AppTextStyles.regular12.copyWith(
                      color: gift.status!.getStatusTextColor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              // Title, Code and Icon
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            gift.title,
                            style: AppTextStyles.medium16.copyWith(
                              color: context.colors.textPrimary,
                            ),
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (gift.code != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              gift.code!,
                              style: AppTextStyles.regular12.copyWith(
                                color: context.colors.textSecondary,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Theme Icon Container
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colors.cardBackGround,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        getThemeIcon(gift.themeIcon),
                        color: context.colors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sub-card details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.cardBackGround,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoRow(
                  context,
                  label: LocaleKeys.gifts_card_sender_name.tr(context: context),
                  value: gift.senderName ?? '',
                ),
                if (gift.message != null && gift.message!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    context,
                    label: LocaleKeys.gifts_card_sent_message.tr(context: context),
                    value: '“${gift.message}”',
                    valueColor: context.colors.textPrimary,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Validity
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.gifts_card_validity.tr(context: context),
                    style: AppTextStyles.regular12.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        LocaleKeys.gifts_card_expires.tr(args: [gift.formattedExpiryDate], context: context),
                        style: AppTextStyles.regular12.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Total
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    LocaleKeys.gifts_card_total.tr(context: context),
                    style: AppTextStyles.regular12.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${gift.totalAmount.toStringAsFixed(2)} ﷼',
                    style: AppTextStyles.medium16.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (showRedeemButton) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRedeemPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Text(
                LocaleKeys.gifts_card_redeem_now.tr(context: context),
                style: AppTextStyles.medium16.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.regular14.copyWith(
              color: valueColor ?? context.colors.textSecondary,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.textSecondary,
          ),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}
