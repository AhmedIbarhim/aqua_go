import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:svg_flutter/svg.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/pricing/gross_price_breakdown.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import '../../data/models/booking_response_model/booking_response_model.dart';

class BookingDetailsSummaryCard extends StatelessWidget {
  final BookingResponseModel booking;

  const BookingDetailsSummaryCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final currency = booking.currency ?? 'SAR';
    final summary = _breakdown();
    final bool isCoveredZero =
        booking.isCoveredBySubscription && summary.totalMinor == 0;
    final bool showItems = !isCoveredZero && summary.lines.isNotEmpty;
    final bool showDiscount = !isCoveredZero && summary.hasDiscount;
    final bool showVat = !isCoveredZero && summary.vatMinor > 0;

    final bool showPointsDiscount = !isCoveredZero && summary.hasPointsDiscount;

    final bool showSubtotal = showDiscount || showPointsDiscount;
    final promo = booking.promo;
    final bool showPromo = promo != null && !promo.isEmpty;

    final bool showTip =
        booking.tipPaid == true &&
        booking.tipAmountMinor != null &&
        booking.tipAmountMinor! > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_booking_summary.tr(context: context),
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              _buildSummaryRow(
                context,
                title: LocaleKeys.bookings_service_name.tr(context: context),
                value: booking.title,
                icon: AppAssets.document,
              ),
              _buildSummaryRow(
                context,
                title: LocaleKeys.bookings_date_and_time.tr(context: context),
                value: booking.formattedDateTime,
                icon: AppAssets.date,
              ),
              if (showItems)
                ...summary.lines.map(
                  (line) => _buildSummaryRow(
                    context,
                    title: line.label,
                    value: '${line.gross.toStringAsFixed(2)} $currency',
                    icon: AppAssets.document,
                  ),
                ),
              if (showSubtotal) ...[
                if (showItems) _buildThinDivider(context),
                _buildSummaryRow(
                  context,
                  title: LocaleKeys.bookings_original_total.tr(
                    context: context,
                  ),
                  value: '${summary.subtotal.toStringAsFixed(2)} $currency',
                  icon: AppAssets.document,
                ),
                if (showDiscount)
                  _buildSummaryRow(
                    context,
                    title: _discountLabel(context),
                    value: '-${summary.discount.toStringAsFixed(2)} $currency',
                    icon: AppAssets.promotion,
                  ),

                if (showPointsDiscount)
                  _buildSummaryRow(
                    context,
                    title: LocaleKeys.bookings_pay_using_points.tr(
                      context: context,
                    ),
                    value:
                        '-${summary.pointsDiscount.toStringAsFixed(2)} $currency',
                    icon: AppAssets.loyalty,
                  ),
                if (showPointsDiscount)
                  _buildSummaryRow(
                    context,
                    title: LocaleKeys.bookings_pay_using_points.tr(
                      context: context,
                    ),
                    value:
                        '-${summary.pointsDiscount.toStringAsFixed(2)} $currency',
                    icon: AppAssets.loyalty,
                  ),
              ],
              if (showItems || showSubtotal) _buildTotalDivider(context),
              _buildSummaryRow(
                context,
                title: LocaleKeys.bookings_total_amount.tr(context: context),
                value: booking.isFromGift == true
                    ? LocaleKeys.gifts_paid_via_gift_coupon.tr(context: context)
                    : booking.isCoveredBySubscription &&
                          booking.totalAmount == 0
                    ? LocaleKeys.bookings_covered_by_subscription.tr(
                        context: context,
                      )
                    : '${booking.totalAmount.toStringAsFixed(2)} $currency',
                icon: AppAssets.currency,
              ),

              if (showVat) _buildVatFootnote(context, summary, currency),

              if (showPromo && promo.isReleased)
                Text(
                  LocaleKeys.bookings_promo_released.tr(context: context),
                  style: AppTextStyles.regular12.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
            ],
          ),
        ),

        if (showTip) ...[
          const SizedBox(height: 12),
          _buildTipSection(context, currency),
        ],
      ],
    );
  }

  Widget _buildTipSection(BuildContext context, String currency) {
    final tipAmount = (booking.tipAmountMinor ?? 0) / 100.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _buildSummaryRow(
        context,
        title: LocaleKeys.bookings_tip_paid_separately.tr(context: context),
        value: '${tipAmount.toStringAsFixed(2)} $currency',
        icon: AppAssets.currency,
      ),
    );
  }

  GrossPriceBreakdown _breakdown() {
    final lines = booking.lines ?? const <QuoteLine>[];
    final discountLine = lines.where((l) => l.isDiscount).firstOrNull;
    final itemLines = <GrossLine>[];

    final serviceLine = lines.where((l) => l.isService).firstOrNull;
    if (serviceLine != null) {
      itemLines.add(
        GrossLine(label: booking.title, grossMinor: serviceLine.grossMinor),
      );
    }
    for (final addon in booking.addOns ?? const <BookingAddon>[]) {
      final match = lines
          .where((l) => l.isAddon && l.refId == addon.addonId)
          .firstOrNull;
      itemLines.add(
        GrossLine(
          label: addon.name,

          grossMinor: match?.grossMinor ?? (addon.chargedMinor ?? 0),
        ),
      );
    }

    final totalAmountMinor = booking.totalAmountMinor ?? 0;
    return GrossPriceBreakdown.fromBookingLines(
      itemLines: itemLines,

      discountMinor: discountLine != null
          ? -discountLine.grossMinor
          : (booking.promo?.discountMinor ?? 0),
      promoCode: booking.promo?.code,
      totalMinor: totalAmountMinor,
      vatMinor: booking.breakdown?.vatMinor ?? 0,
      pointsDiscountMinor: booking.promoPoints?.pointsDiscountMinor ?? 0,
    );
  }

  String _discountLabel(BuildContext context) {
    final code = booking.promo?.code;
    if (code == null || code.isEmpty) {
      return LocaleKeys.bookings_promo_discount.tr(context: context);
    }
    return LocaleKeys.bookings_promo_discount_named.tr(
      context: context,
      args: [code],
    );
  }

  Widget _buildVatFootnote(
    BuildContext context,
    GrossPriceBreakdown summary,
    String currency,
  ) {
    final style = AppTextStyles.regular12.copyWith(
      color: context.colors.textTertiary,
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
          child: Text(
            '${summary.vat.toStringAsFixed(2)} $currency',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: style,
          ),
        ),
      ],
    );
  }

  Widget _buildThinDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: context.colors.borderSecondary.withValues(alpha: 0.25),
    );
  }

  Widget _buildTotalDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.colors.borderSecondary.withValues(alpha: 0.6),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String title,
    required String value,
    required String icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  context.colors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.regular14.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: AppTextStyles.regular14.copyWith(
              color: context.colors.contentSecondaryLight,
            ),
          ),
        ),
      ],
    );
  }
}
