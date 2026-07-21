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

  const PaymentSummaryCard({
    super.key,
    required this.serviceName,
    required this.servicePrice,
    required this.additionalItems,
    required this.subtotal,
    required this.vat,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    // Split the extra rows into POSITIVE line items (add-ons — rendered above the
    // totals block with the service) and NEGATIVE tender lines (e.g. redeemed
    // loyalty points). A points redemption is a TENDER that lowers the card
    // charge, not a line item that changes the taxable subtotal — so it must sit
    // BELOW the Total, right before "Card charged", or the ledger doesn't
    // reconcile (a −points row floating among the line items makes
    // Subtotal + VAT ≠ Total ≠ the running item sum).
    final List<Map<String, dynamic>> lineItems = additionalItems
        .where((i) => ((i['price'] as num?) ?? 0) >= 0)
        .toList();
    final List<Map<String, dynamic>> tenderItems = additionalItems
        .where((i) => ((i['price'] as num?) ?? 0) < 0)
        .toList();

    // `total` is the amount actually charged (already post-points). Adding the
    // tender back yields the invoice Total that Subtotal + VAT reconcile to —
    // a pure display derivation (no number is changed). With no tender lines
    // this equals `total`, so the layout is identical to before.
    final double tenderSum = tenderItems.fold<double>(
      0,
      (sum, i) => sum + ((i['price'] as num?)?.toDouble() ?? 0),
    );
    final double invoiceTotal = total - tenderSum;
    final bool hasTender = tenderItems.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPaymentRow(context, label: serviceName, value: servicePrice),
        ...lineItems.map(
          (item) => Column(
            children: [
              const SizedBox(height: 12),
              Divider(
                height: 1,
                thickness: 0.5,
                color: context.colors.borderSecondary.withValues(alpha: 0.25),
              ),
              const SizedBox(height: 12),
              _buildPaymentRow(
                context,
                label: item['name'],
                value: (item['price'] as num).toDouble(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Distinct (slightly more visible) separator between the line items and
        // the totals block — set apart from the subtle inter-item dividers.
        Divider(
          height: 1,
          thickness: 1,
          color: context.colors.borderSecondary.withValues(alpha: 0.6),
        ),
        const SizedBox(height: 12),
        _buildPaymentRow(
          context,
          label: LocaleKeys.bookings_subtotal.tr(context: context),
          value: subtotal,
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 0.5),
        const SizedBox(height: 12),
        _buildPaymentRow(
          context,
          label: LocaleKeys.bookings_vat.tr(context: context),
          value: vat,
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 1, color: Colors.white),
        const SizedBox(height: 12),
        // Invoice Total = Subtotal + VAT. When points were redeemed it is NOT the
        // final emphasised figure (the card charge is) — the emphasis moves to
        // the "Card charged" row below so the reconciling ledger reads
        // Total → − Points → Card charged.
        _buildPaymentRow(
          context,
          label: LocaleKeys.bookings_total_amount.tr(context: context),
          value: invoiceTotal,
          isTotal: !hasTender,
        ),
        // Tender lines (redeemed points) sit below the Total, then the final
        // "Card charged" row = `total` (the amount actually charged on-device).
        if (hasTender) ...[
          ...tenderItems.map(
            (item) => Column(
              children: [
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: context.colors.borderSecondary.withValues(alpha: 0.25),
                ),
                const SizedBox(height: 12),
                _buildPaymentRow(
                  context,
                  label: item['name'],
                  value: (item['price'] as num).toDouble(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            thickness: 1,
            color: context.colors.borderSecondary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          _buildPaymentRow(
            context,
            label: LocaleKeys.bookings_card_charged.tr(context: context),
            value: total,
            isTotal: true,
          ),
        ],
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
