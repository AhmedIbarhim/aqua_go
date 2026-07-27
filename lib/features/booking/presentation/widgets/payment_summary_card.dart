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

  /// What the applied promo code took off this order, in SAR. 0 when no code
  /// is applied — the discount group is then not rendered at all.
  final double promoDiscount;

  const PaymentSummaryCard({
    super.key,
    required this.serviceName,
    required this.servicePrice,
    required this.additionalItems,
    required this.subtotal,
    required this.vat,
    required this.total,
    this.promoDiscount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPaymentRow(context, label: serviceName, value: servicePrice),
        ...additionalItems.map(
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
                value: item['price'],
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
        // PROMO IS ALREADY NETTED OUT — DO NOT ADD A DISCOUNT ROW HERE.
        // `subtotal`, `vat` and `total` come straight from the backend quote
        // breakdown, and PriceQuoteServiceImpl subtracts the promo from the
        // surged gross BEFORE splitting VAT:
        //   discountedGross = surgedGross - appliedDiscount
        //   serviceNetMinor = discountedGross - serviceVatMinor
        // Even `servicePrice` above is the post-discount SERVICE line net.
        // Inserting an arithmetic `-promoDiscount` row between Subtotal and VAT
        // double-subtracts and the column stops adding up: base gross 11500 with
        // a 2000 promo would render 82.61 / -20.00 / 12.39 / 95.00, and
        // 82.61 - 20.00 + 12.39 = 75.00, not 95.00. The applied code is surfaced
        // by PromoCodeSection's chip instead.
        // Locked by test/features/booking/payment_summary_reconciliation_test.dart.
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
        // UCC16 step 4 — "breakdown shown (original, discount, new total)".
        // These two rows plus the Total row below ARE those three values, and
        // they are a SEPARATE statement from the Subtotal/VAT column above:
        // original − discount == total, while subtotal + VAT == total. Nothing
        // above is recomputed, so neither statement disturbs the other. The
        // original is reconstructed as total + discount, which is exact —
        // PriceQuoteServiceImpl subtracts the discount from the VAT-inclusive
        // surged gross to get this very total (discountedGross = surgedGross −
        // appliedDiscount), so adding it back is the same figure, not an
        // estimate.
        if (promoDiscount > 0) ...[
          _buildPaymentRow(
            context,
            label: LocaleKeys.bookings_original_total.tr(context: context),
            value: total + promoDiscount,
          ),
          const SizedBox(height: 12),
          _buildPaymentRow(
            context,
            label: LocaleKeys.bookings_promo_discount.tr(context: context),
            value: promoDiscount,
            negative: true,
          ),
          const SizedBox(height: 12),
        ],
        _buildPaymentRow(
          context,
          label: LocaleKeys.bookings_total_amount.tr(context: context),
          value: total,
          isTotal: true,
        ),
      ],
    );
  }

  /// Both halves are [Flexible], so each keeps its natural width while the pair
  /// fits and gives ground only when it does not. Without that the row is two
  /// unbounded `Text`s and overflows on a phone: a long add-on name, and the
  /// Arabic labels — which run longer than the English ones, the two promo rows
  /// most of all — push past the card edge. Same fix, and the same reason, as
  /// `BookingDetailsSummaryCard._buildSummaryRow`.
  ///
  /// Nothing here branches on direction. [Flexible] and [MainAxisAlignment
  /// .spaceBetween] are direction-agnostic; Flutter lays the same tree out RTL
  /// in Arabic.
  Widget _buildPaymentRow(
    BuildContext context, {
    required String label,
    required double value,
    bool isTotal = false,
    bool negative = false,
  }) {
    final style = (isTotal ? AppTextStyles.medium16 : AppTextStyles.regular16)
        .copyWith(
          color: isTotal
              ? context.colors.textPrimary
              : context.colors.textSecondary,
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  '${negative ? '-' : ''}${value.toStringAsFixed(2)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: style,
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
        ),
      ],
    );
  }
}
