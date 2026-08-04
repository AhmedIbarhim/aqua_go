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
    // A gift-redeemed / covered-wash booking carries no points concept
    // (0 pricing throughout, see `title` row's copy branches below), so the
    // points row is suppressed the same way the promo/VAT rows already are.
    final bool showPointsDiscount = !isCoveredZero && summary.hasPointsDiscount;
    // The "before discount" subtotal exists to explain whichever of the two
    // discount rows below it render — a promo, points, or both. With neither,
    // it would just restate the total and is suppressed the same way.
    final bool showSubtotal = showDiscount || showPointsDiscount;
    final promo = booking.promo;
    final bool showPromo = promo != null && !promo.isEmpty;
    // The tip is its own payment, charged after the wash — never part of
    // `totalAmountMinor` and never folded into the card above. Gated on the
    // backend's own confirmation (`tipPaid`), so an unpaid/no-tip booking
    // renders nothing here.
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
                // Points are a discount on the taxable base, exactly like the
                // promo row above — not a separate tender — so this row walks
                // the subtotal down to Total below it the same way the promo
                // row does. `totalAmountMinor` already has this saving folded
                // in; there is no separate "Card charged" row any more, since
                // it would always equal Total and just restate the same
                // number twice.
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
              // VAT is a DISCLOSURE, not a step in the sum: it is already
              // inside the total above. Smaller and muted, under the total, so
              // it cannot be read as an addend. It is the VAT actually charged
              // — computed by the backend on the DISCOUNTED gross — and is
              // never recomputed here.
              if (showVat) _buildVatFootnote(context, summary, currency),
              // A released redemption no longer counts against the campaign,
              // but the discount it granted still shaped what this booking was
              // charged — so the state is stated, rather than silently
              // disappearing on cancellation.
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
        // The tip: a SEPARATE payment from the wash total above, so it gets
        // its own card rather than a row inside the summary — folding it in
        // would misstate what the total above was charged for.
        if (showTip) ...[
          const SizedBox(height: 12),
          _buildTipSection(context, currency),
        ],
      ],
    );
  }

  /// The tip, in its own card below the payment summary. Kept visually and
  /// structurally separate from `totalAmountMinor` above: this money moved on
  /// its own payment intent, after the wash was already charged and paid for.
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

  /// The VAT-inclusive breakdown this card renders.
  ///
  /// Every figure is backend-sourced. On a booking that carried a code the
  /// backend rebuilds its lines so the SERVICE row holds the PRE-discount wash
  /// price and a negative DISCOUNT line holds the saving — so Σ (SERVICE +
  /// ADDON) gross is the "before discount" subtotal, and that minus the
  /// discount is the charged total. Nothing here recomputes VAT.
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
          // The backend line is authoritative; `charged` is the read-path
          // fallback for a booking whose lines the backend omitted, and is a
          // gross figure too.
          grossMinor: match?.grossMinor ?? (addon.chargedMinor ?? 0),
        ),
      );
    }

    final totalAmountMinor = booking.totalAmountMinor ?? 0;
    return GrossPriceBreakdown.fromBookingLines(
      itemLines: itemLines,
      // The DISCOUNT line's gross is NEGATIVE; the display value is its
      // magnitude. Falls back to the promo view's own discount when the line is
      // absent (read path), which is the same figure.
      discountMinor: discountLine != null
          ? -discountLine.grossMinor
          : (booking.promo?.discountMinor ?? 0),
      promoCode: booking.promo?.code,
      totalMinor: totalAmountMinor,
      vatMinor: booking.breakdown?.vatMinor ?? 0,
      pointsDiscountMinor: booking.promoPoints?.pointsDiscountMinor ?? 0,
    );
  }

  /// "Discount NEWCUST50" — the code named in the row that states its value.
  /// Falls back to the unnamed label when the discount arrived without a code,
  /// so the row never reads "Discount null".
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

  /// The inclusive-VAT disclosure under the total: smaller and muted, so it
  /// cannot be read as an addend.
  Widget _buildVatFootnote(
    BuildContext context,
    GrossPriceBreakdown summary,
    String currency,
  ) {
    final style = AppTextStyles.regular12.copyWith(
      // textTertiary, not contentDisabled: still clearly subordinate to the
      // total above it, but legible on the light card (see the note on the
      // summary-row label).
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

  /// Very subtle hairline used BETWEEN line items and between the net and VAT
  /// rows inside the totals block.
  Widget _buildThinDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: context.colors.borderSecondary.withValues(alpha: 0.25),
    );
  }

  /// Slightly more visible separator between the (net + VAT) block and the
  /// final grand total.
  Widget _buildTotalDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.colors.borderSecondary.withValues(alpha: 0.6),
    );
  }

  /// Both halves are [Flexible], so each keeps its natural width while the pair
  /// fits and gives ground only when it does not. Without that the row is two
  /// unbounded `Text`s and overflows: an add-on with a long name, a date-and-time
  /// line, and the Arabic labels — which run longer than the English ones — all
  /// pushed past the card edge on a phone-width screen.
  ///
  /// Nothing here branches on direction. `Flexible` and `spaceBetween` are
  /// direction-agnostic; Flutter lays the same tree out RTL in Arabic.
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
                  // Same reasoning as the label below — the icon shares the
                  // label's weight, so it shares its colour.
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
                    // NOT contentDisabled. In the LIGHT palette that token is #CCD0D7, which sits
                    // at ~1.1:1 against this card's #E6E7E9 — the label column rendered as a
                    // ghost. It only looked fine in dark, where the same token is #737373.
                    // These labels are muted, not DISABLED; textSecondary is the token the
                    // equivalent row in PaymentSummaryCard already uses.
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
