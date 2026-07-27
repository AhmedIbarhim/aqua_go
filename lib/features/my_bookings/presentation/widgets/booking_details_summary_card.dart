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
    // A covered subscription wash keeps the single "covered by subscription"
    // total row untouched — there is no money to itemise.
    final bool isCoveredZero =
        booking.isCoveredBySubscription && summary.totalMinor == 0;
    // Each money row is gated on the data it needs, INDEPENDENTLY. Gating them
    // together on the presence of `breakdown` would drop the discount from a
    // booking whose payload carries a promo but no breakdown — a read path that
    // must keep rendering what it does have.
    final bool showItems = !isCoveredZero && summary.lines.isNotEmpty;
    final bool showDiscount = !isCoveredZero && summary.hasDiscount;
    final bool showVat = !isCoveredZero && summary.vatMinor > 0;
    // UCC16 — the customer can see the discount that applied to THEIR booking,
    // on the booking itself and not only on the review screen they passed
    // through once. A code that priced to nothing on this basket states no
    // saving, rather than a "0.00 off" row that reads as a bug — but a RELEASED
    // code still gets its note below, because it shaped what was charged.
    final promo = booking.promo;
    final bool showPromo = promo != null && !promo.isEmpty;
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
              // Line items — VAT-INCLUSIVE and PRE-discount, straight from the
              // backend's own SERVICE / ADDON lines. The backend rebuilds the
              // breakdown so the SERVICE row states the wash's true (pre-
              // discount) price, which is why these rows sum exactly to the
              // "before discount" subtotal beneath them. No client math.
              if (showItems)
                ...summary.lines.map(
                  (line) => _buildSummaryRow(
                    context,
                    title: line.label,
                    value: '${line.gross.toStringAsFixed(2)} $currency',
                    icon: AppAssets.document,
                  ),
                ),
              // The subtotal and discount rows exist ONLY to explain a
              // discount. With no code applied a "before discount" figure would
              // just restate the total, so both rows go and the lines run
              // straight into the total.
              if (showDiscount) ...[
                if (showItems) _buildThinDivider(context),
                _buildSummaryRow(
                  context,
                  title: LocaleKeys.bookings_original_total.tr(
                    context: context,
                  ),
                  value: '${summary.subtotal.toStringAsFixed(2)} $currency',
                  icon: AppAssets.document,
                ),
                // The discount, ONCE, at its full VAT-inclusive value,
                // immediately above the total it produces. The code is folded
                // into the label, so there is no separate "Promo code" row.
                _buildSummaryRow(
                  context,
                  title: _discountLabel(context),
                  value: '-${summary.discount.toStringAsFixed(2)} $currency',
                  icon: AppAssets.promotion,
                ),
              ],
              if (showItems || showDiscount) _buildTotalDivider(context),
              // Exactly ONE grand total, VAT-inclusive (gross), emphasised.
              _buildSummaryRow(
                context,
                title: LocaleKeys.bookings_total_amount.tr(context: context),
                value:
                    booking.isCoveredBySubscription && booking.totalAmount == 0
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
                    color: context.colors.contentDisabled,
                  ),
                ),
            ],
          ),
        ),
      ],
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

    return GrossPriceBreakdown.fromBookingLines(
      itemLines: itemLines,
      // The DISCOUNT line's gross is NEGATIVE; the display value is its
      // magnitude. Falls back to the promo view's own discount when the line is
      // absent (read path), which is the same figure.
      discountMinor: discountLine != null
          ? -discountLine.grossMinor
          : (booking.promo?.discountMinor ?? 0),
      promoCode: booking.promo?.code,
      totalMinor: booking.totalAmountMinor ?? 0,
      vatMinor: booking.breakdown?.vatMinor ?? 0,
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
                  context.colors.contentDisabled,
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
                    color: context.colors.contentDisabled,
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
