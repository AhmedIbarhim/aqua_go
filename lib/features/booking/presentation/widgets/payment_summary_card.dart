import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';

class PaymentSummaryCard extends StatelessWidget {
  final String serviceName;
  final double servicePrice;
  final List<Map<String, dynamic>> additionalItems;
  final double subtotal;
  final double vat;
  final double total;

  /// When true, every line item (service + add-ons) is shown VAT-inclusive and
  /// the VAT row is rendered as an informational "VAT 15% included" note instead
  /// of an additive numeric line, so the breakdown reconciles (sum of line items
  /// == total).
  final bool vatInclusive;

  /// When true, the wash is pre-paid by an active subscription. The per-wash
  /// total is meaningless (0 / NOT_REQUIRED), so the money sub-rows (service,
  /// add-ons, subtotal, VAT) are suppressed and the grand-total value reads as
  /// the localized "Covered by subscription" text instead of a bare "0.00".
  final bool isCoveredBySubscription;

  const PaymentSummaryCard({
    super.key,
    required this.serviceName,
    required this.servicePrice,
    required this.additionalItems,
    required this.subtotal,
    required this.vat,
    required this.total,
    this.vatInclusive = false,
    this.isCoveredBySubscription = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCoveredBySubscription) {
      return _buildCoveredRow(context);
    }
    return Column(
      children: [
        _buildPaymentRow(context, label: serviceName, value: servicePrice),
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
        if (!vatInclusive) ...[
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 12),
          _buildPaymentRow(
            context,
            label: LocaleKeys.bookings_subtotal.tr(),
            value: subtotal,
          ),
        ],
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 0.5),
        const SizedBox(height: 12),
        if (vatInclusive)
          _buildVatIncludedRow(context)
        else
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

  Widget _buildCoveredRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          LocaleKeys.bookings_total_amount.tr(),
          style: AppTextStyles.medium16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        Text(
          LocaleKeys.bookings_covered_by_subscription.tr(),
          style: AppTextStyles.medium16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildVatIncludedRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          LocaleKeys.bookings_vat_included.tr(),
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textSecondary,
          ),
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
