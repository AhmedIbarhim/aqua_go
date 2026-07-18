import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../data/models/gift_model.dart';

class SentGiftCard extends StatelessWidget {
  final GiftModel gift;

  const SentGiftCard({super.key, required this.gift});

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
    final cardBgColor = _parseHexColor(
      gift.themeColor,
      context.colors.cardBackGround,
    );

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
              // Title, Code and Icon
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Theme Icon Container
                    Container(
                      width: context.sw(40),
                      height: context.sw(40),
                      decoration: BoxDecoration(
                        color: context.colors.cardBackGround,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        gift.themeImageUrl ?? "",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.card_giftcard_outlined,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                  ],
                ),
              ),

              if (gift.status != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBgColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoRow(
                  context,
                  label: LocaleKeys.gifts_card_recipient_name.tr(
                    context: context,
                  ),
                  value: gift.recipientName ?? '',
                ),
                if (gift.recipientPhone != null) ...[
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    context,
                    label: LocaleKeys.gifts_card_mobile_number.tr(
                      context: context,
                    ),
                    value: gift.recipientPhone!,
                  ),
                ],
                if (gift.message != null && gift.message!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    context,
                    label: LocaleKeys.gifts_card_sent_message.tr(
                      context: context,
                    ),
                    value: '',
                    valueColor: context.colors.textPrimary,
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      '"${gift.message}"',
                      style: AppTextStyles.regular14.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
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
              // Total
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.gifts_card_total.tr(context: context),
                    style: AppTextStyles.regular12.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${gift.totalAmount.toStringAsFixed(2)} ${_getCurrency(context)}',
                    style: AppTextStyles.medium16.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

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
                          args: [gift.formattedExpiryDate],
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
            ],
          ),
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
        Text(
          label,
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.textSecondary,
          ),
          textAlign: TextAlign.end,
        ),
        const SizedBox(width: 8),

        Expanded(
          child: Text(
            value,
            style: AppTextStyles.regular14.copyWith(
              color: valueColor ?? context.colors.textSecondary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _getCurrency(BuildContext context) {
    return context.isAr ? '﷼' : 'SAR';
  }
}
