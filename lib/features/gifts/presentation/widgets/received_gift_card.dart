import 'package:aqua_go/core/components/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../data/models/gift_model.dart';
import '../../data/models/received_gifts_list_response_model.dart';

class ReceivedGiftCard extends StatelessWidget {
  final ReceivedGiftModel gift;
  final VoidCallback onRedeemPressed;

  const ReceivedGiftCard({
    super.key,
    required this.gift,
    required this.onRedeemPressed,
  });

  Color _parseHexColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty || hexString == "string") {
      return fallback;
    }
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final giftStatus = GiftStatus.fromString(gift.status) ?? GiftStatus.ISSUED;

    final bool showRedeemButton =
        giftStatus == GiftStatus.ISSUED || giftStatus == GiftStatus.DELIVERED;

    final String title = context.isAr
        ? gift.serviceName.ar
        : gift.serviceName.en;
    final String formattedExpiryDate = DateFormat(
      'yyyy/MM/dd',
    ).format(gift.validityEndsAt);

    final cardBgColor = _parseHexColor(
      gift.themeColor,
      context.colors.themeColor,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: giftStatus.getStatusBg(context),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  giftStatus.getStatusText(context),
                  style: AppTextStyles.regular12.copyWith(
                    color: giftStatus.getStatusTextColor(context),
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
                            title,
                            style: AppTextStyles.medium16.copyWith(
                              color: context.colors.textPrimary,
                            ),
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            gift.giftCode,
                            style: AppTextStyles.regular12.copyWith(
                              color: context.colors.textSecondary,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Theme Image/Icon Container
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.colors.cardBackGround,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child:
                          gift.themeImageUrl != null &&
                              gift.themeImageUrl!.isNotEmpty &&
                              gift.themeImageUrl != "string"
                          ? Image.network(
                              gift.themeImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.card_giftcard_outlined,
                                    color: Colors.grey,
                                  ),
                            )
                          : Icon(
                              Icons.card_giftcard_outlined,
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
              color: cardBgColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoColumn(
                  context,
                  label: LocaleKeys.gifts_card_sender_name.tr(context: context),
                  value: gift.senderName,
                ),
                if (gift.messageText.isNotEmpty &&
                    gift.messageText != "string") ...[
                  const SizedBox(height: 10),
                  _buildInfoColumn(
                    context,
                    label: LocaleKeys.gifts_card_sent_message.tr(
                      context: context,
                    ),
                    value: '“${gift.messageText}”',
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
                        LocaleKeys.gifts_card_expires.tr(
                          args: [formattedExpiryDate],
                          context: context,
                        ),
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
                    '${gift.amount.toStringAsFixed(2)} ﷼',
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
            CustomButton(
              onPressed: onRedeemPressed,
              text: LocaleKeys.gifts_card_redeem_now.tr(context: context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        Text(value, style: AppTextStyles.medium14, maxLines: 3),
      ],
    );
  }
}
