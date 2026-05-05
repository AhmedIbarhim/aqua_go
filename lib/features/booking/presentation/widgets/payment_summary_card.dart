import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';

class PaymentSummaryCard extends StatelessWidget {
  final double servicePrice;
  final List<Map<String, dynamic>> additionalItems;
  final double subtotal;
  final double vat;
  final double total;

  const PaymentSummaryCard({
    super.key,
    required this.servicePrice,
    required this.additionalItems,
    required this.subtotal,
    required this.vat,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPaymentRow(
          context,
          label:
              'غسلة داخلي و خارجي', // This should be dynamic based on selected service
          value: servicePrice,
        ),
        ...additionalItems.map(
          (item) => Column(
            children: [
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 12),
              _buildPaymentRow(
                context,
                label: item['name'],
                value: item['price'],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 0.5),
        const SizedBox(height: 12),
        _buildPaymentRow(
          context,
          label: LocaleKeys.bookings_subtotal.tr(),
          value: subtotal,
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 0.5),
        const SizedBox(height: 12),
        _buildPaymentRow(
          context,
          label: LocaleKeys.bookings_vat.tr(),
          value: vat,
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 1, color: Colors.white),
        const SizedBox(height: 12),
        _buildPaymentRow(
          context,
          label: LocaleKeys.bookings_total_amount.tr(),
          value: total,
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildPaymentRow(
    BuildContext context, {
    required String label,
    required double value,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isTotal ? AppTextStyles.medium16 : AppTextStyles.regular16)
              .copyWith(
                color: isTotal
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
              ),
        ),
        Row(
          children: [
            Text(
              value.toStringAsFixed(2),
              style:
                  (isTotal ? AppTextStyles.medium16 : AppTextStyles.regular16)
                      .copyWith(
                        color: isTotal
                            ? context.colors.textPrimary
                            : context.colors.textSecondary,
                      ),
            ),

            const SizedBox(width: 4),

            SvgPicture.asset(
              AppAssets.currency,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isTotal
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
