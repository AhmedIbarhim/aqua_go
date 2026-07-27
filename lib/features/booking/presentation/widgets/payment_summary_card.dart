import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/pricing/gross_price_breakdown.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';

/// The review screen's price breakdown, VAT-INCLUSIVE throughout.
///
/// Every visible figure is gross, so the customer recognises the catalogue
/// prices they picked and sees the discount at the value they were promised.
/// The shape is [GrossPriceBreakdown]'s — see that type for the layout and for
/// why no net figure and no second discount row appear here.
///
/// This card renders the SAME rows as `BookingDetailsSummaryCard`; both are fed
/// by [GrossPriceBreakdown] so the review screen and the booking detail cannot
/// state different prices for the same order.
class PaymentSummaryCard extends StatelessWidget {
  final GrossPriceBreakdown breakdown;

  const PaymentSummaryCard({super.key, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line items — VAT-inclusive, pre-discount. These sum to the subtotal
        // below, which is what makes the column followable by eye.
        for (final (i, line) in breakdown.lines.indexed) ...[
          if (i > 0) ...[
            const SizedBox(height: 12),
            Divider(
              height: 1,
              thickness: 0.5,
              color: context.colors.borderSecondary.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
          ],
          _buildPaymentRow(context, label: line.label, value: line.gross),
        ],
        // The subtotal and discount rows exist ONLY to explain a discount. With
        // no code applied a "before discount" figure would just restate the
        // total, so both rows go and the lines run straight into the total.
        if (breakdown.hasDiscount) ...[
          const SizedBox(height: 12),
          // Distinct (slightly more visible) separator between the line items
          // and the totals block — set apart from the subtle inter-item ones.
          Divider(
            height: 1,
            thickness: 1,
            color: context.colors.borderSecondary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          _buildPaymentRow(
            context,
            label: LocaleKeys.bookings_original_total.tr(context: context),
            value: breakdown.subtotal,
          ),
          const SizedBox(height: 12),
          // The discount, ONCE, at its full VAT-inclusive value, immediately
          // above the total it produces. The code is folded into the label, so
          // there is no separate "Promo code" row. Tone matches every other
          // non-total row: the app states a saving in muted text (the promo
          // chip's "you saved" line), never in a positive/green colour.
          _buildPaymentRow(
            context,
            label: _discountLabel(context),
            value: breakdown.discount,
            negative: true,
          ),
        ],
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 1, color: Colors.white),
        const SizedBox(height: 12),
        _buildPaymentRow(
          context,
          label: LocaleKeys.bookings_total_amount.tr(context: context),
          value: breakdown.total,
          isTotal: true,
        ),
        const SizedBox(height: 8),
        // VAT is a DISCLOSURE, not a step in the sum: it is already inside the
        // total above. It sits under the total, smaller and muted, so it cannot
        // be read as an addend. The figure is the VAT actually charged — the
        // backend computed it on the DISCOUNTED gross — and is never recomputed
        // here; VAT on the pre-discount subtotal would be a larger, wrong
        // number.
        _buildVatFootnote(context),
      ],
    );
  }

  /// "Discount NEWCUST50" — the code named in the row that states its value.
  /// Falls back to the unnamed label when the discount arrived without a code
  /// (an admin goodwill adjustment), so the row never reads "Discount null".
  String _discountLabel(BuildContext context) {
    final code = breakdown.promoCode;
    if (code == null || code.isEmpty) {
      return LocaleKeys.bookings_promo_discount.tr(context: context);
    }
    return LocaleKeys.bookings_promo_discount_named.tr(
      context: context,
      args: [code],
    );
  }

  Widget _buildVatFootnote(BuildContext context) {
    final style = AppTextStyles.regular12.copyWith(
      color: context.colors.contentDisabled,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            LocaleKeys.bookings_vat_inclusive.tr(context: context),
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
                  breakdown.vat.toStringAsFixed(2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: style,
                ),
              ),
              const SizedBox(width: 4),
              SvgPicture.asset(
                AppAssets.currency,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  context.colors.contentDisabled,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Both halves are [Flexible], so each keeps its natural width while the pair
  /// fits and gives ground only when it does not. Without that the row is two
  /// unbounded `Text`s and overflows on a phone: a long add-on name, and the
  /// Arabic labels — which run longer than the English ones — push past the
  /// card edge. Same fix, and the same reason, as
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
