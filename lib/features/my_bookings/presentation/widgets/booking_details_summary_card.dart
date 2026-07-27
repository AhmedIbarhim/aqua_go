import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:svg_flutter/svg.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import '../../data/models/booking_response_model/booking_response_model.dart';

class BookingDetailsSummaryCard extends StatelessWidget {
  final BookingResponseModel booking;

  const BookingDetailsSummaryCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final currency = booking.currency ?? 'SAR';
    final hasAddons = booking.addOns != null && booking.addOns!.isNotEmpty;
    final breakdown = booking.breakdown;
    // Show the net-subtotal / VAT summary only for a real money breakdown
    // (paid booking with add-ons). Covered subscription washes keep the single
    // "covered by subscription" total row untouched.
    final bool showNetVatSummary =
        hasAddons &&
        breakdown != null &&
        (!booking.isCoveredBySubscription || (breakdown.grossMinor ?? 0) != 0);
    // UCC16 — the customer can see the discount that applied to THEIR booking,
    // on the booking itself and not only on the review screen they passed
    // through once. A code that priced to nothing on this basket is still NAMED
    // — it was redeemed against this booking, and the review screen says so too
    // — but it states no saving, rather than a "0.00 off" pair that reads as a
    // bug.
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
              // Service's OWN price line (NET) — sourced from the SERVICE line's
              // netMinor, the same source the add-on rows use. Shown only for a
              // real money breakdown (not covered subscription washes), so the
              // service appears with a price like the add-ons. No client math;
              // it does NOT change the backend-sourced subtotal/total below.
              if (showNetVatSummary)
                _buildSummaryRow(
                  context,
                  title: LocaleKeys.bookings_service_price.tr(context: context),
                  value: _serviceNet() == 0.0
                      ? LocaleKeys.bookings_covered_by_subscription.tr(
                          context: context,
                        )
                      : '${_serviceNet().toStringAsFixed(2)} $currency',
                  icon: AppAssets.document,
                ),
              // Add-on rows render NET (Option B): take the matching ADDON line's
              // netMinor (matched by addonId → line.refId) — no client math. Fall
              // back to charged only if the backend omitted the line (read path).
              if (hasAddons)
                ...booking.addOns!.map((addon) {
                  final addonPrice = _addonNet(addon);
                  return _buildSummaryRow(
                    context,
                    title: addon.name,
                    value: addonPrice == 0.0
                        ? LocaleKeys.bookings_covered_by_subscription.tr(
                            context: context,
                          )
                        : '${addonPrice.toStringAsFixed(2)} $currency',
                    icon: AppAssets.terms,
                  );
                }),
              // The negative DISCOUNT row, sourced from the backend's own line.
              //
              // The SERVICE row above states the wash's PRE-discount price (the
              // backend rebuilds the breakdown that way so the true price of
              // what was bought is visible), which means the item rows no longer
              // add up to the Subtotal beneath them unless the saving is stated
              // as its own row. It is a NET figure, like every row in this
              // column — which is why it is labelled "before VAT" and differs
              // from the VAT-inclusive discount in the promo block further down.
              if (showNetVatSummary && _discountNet() != null)
                _buildSummaryRow(
                  context,
                  title: LocaleKeys.bookings_promo_discount_before_vat.tr(
                    context: context,
                  ),
                  value:
                      '${_discountNet()!.toStringAsFixed(2)} $currency',
                  icon: AppAssets.money,
                ),
              if (showNetVatSummary) ...[
                // Totals block, bottom-up: subtotal (net) → VAT → grand total.
                // Subtle hairline between the line items above and the net row,
                // and between net and VAT; a more visible separator before the
                // grand total. All amounts are backend-sourced — no client math.
                _buildThinDivider(context),
                _buildSummaryRow(
                  context,
                  title: LocaleKeys.bookings_subtotal.tr(context: context),
                  value: '${breakdown.net.toStringAsFixed(2)} $currency',
                  icon: AppAssets.document,
                ),
                _buildThinDivider(context),
                _buildSummaryRow(
                  context,
                  title: LocaleKeys.bookings_vat.tr(context: context),
                  value: '${breakdown.vat.toStringAsFixed(2)} $currency',
                  icon: AppAssets.document,
                ),
                _buildTotalDivider(context),
              ],
              // The promo statement, mirroring the review screen's
              // original − discount == total. It is a SEPARATE statement from
              // the Subtotal/VAT column above, which reads subtotal + VAT ==
              // total; nothing above is recomputed, so the two do not disturb
              // each other. `discountMinor` is already netted off
              // `totalAmountMinor`, so the original is reconstructed as
              // total + discount — exact, because the backend subtracts the
              // discount from the VAT-inclusive surged gross to reach this very
              // total.
              if (showPromo) ...[
                if (!showNetVatSummary) _buildTotalDivider(context),
                _buildSummaryRow(
                  context,
                  title: LocaleKeys.bookings_promo_code_title.tr(
                    context: context,
                  ),
                  value: promo.code!,
                  icon: AppAssets.gift,
                ),
                if (promo.hasDiscount) ...[
                  _buildSummaryRow(
                    context,
                    title: LocaleKeys.bookings_original_total.tr(
                      context: context,
                    ),
                    value:
                        '${(booking.totalAmount + promo.discount).toStringAsFixed(2)} $currency',
                    icon: AppAssets.document,
                  ),
                  _buildSummaryRow(
                    context,
                    title: LocaleKeys.bookings_promo_discount.tr(
                      context: context,
                    ),
                    value: '-${promo.discount.toStringAsFixed(2)} $currency',
                    icon: AppAssets.money,
                  ),
                ],
                // A released redemption no longer counts against the campaign,
                // but the discount it granted still shaped what this booking was
                // charged — so the rows stay and the state is stated, rather
                // than the whole block silently disappearing on cancellation.
                if (promo.isReleased)
                  Text(
                    LocaleKeys.bookings_promo_released.tr(context: context),
                    style: AppTextStyles.regular12.copyWith(
                      color: context.colors.contentDisabled,
                    ),
                  ),
                _buildTotalDivider(context),
              ],
              // Exactly ONE grand total, last, VAT-inclusive (gross).
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
            ],
          ),
        ),
      ],
    );
  }

  /// NET amount for an add-on row, sourced from the backend ADDON line
  /// (netMinor) matched by addonId → QuoteLine.refId. No client-side VAT math:
  /// falls back to the gross `charged` only when the line is absent (read path).
  double _addonNet(BookingAddon addon) {
    final lines = booking.lines ?? const <QuoteLine>[];
    final matches = lines.where((l) => l.isAddon && l.refId == addon.addonId);
    return matches.isEmpty ? addon.charged : matches.first.net;
  }

  /// The DISCOUNT line's NET amount (already negative), or null when this
  /// booking carried no code.
  ///
  /// Read from the line, never computed: the backend splits VAT off the
  /// discount at the canonical rate and lands the rounding residue on the
  /// SERVICE row, so recomputing it here would disagree with the Subtotal by a
  /// halala on some baskets.
  double? _discountNet() {
    final lines = booking.lines ?? const <QuoteLine>[];
    final line = lines.where((l) => l.isDiscount).firstOrNull;
    return line?.net;
  }

  /// NET amount for the SERVICE's own line, sourced from the backend SERVICE
  /// line (netMinor) — the same source the add-on rows use. No client-side VAT
  /// math. Falls back to the breakdown net minus the add-on nets only when the
  /// SERVICE line is absent (read path), so the service still shows a price.
  double _serviceNet() {
    final lines = booking.lines ?? const <QuoteLine>[];
    final serviceLine = lines.where((l) => l.isService).firstOrNull;
    if (serviceLine != null) return serviceLine.net;
    final breakdown = booking.breakdown;
    if (breakdown == null) return 0.0;
    final addonsNet = (booking.addOns ?? const <BookingAddon>[]).fold<double>(
      0.0,
      (sum, a) => sum + _addonNet(a),
    );
    return breakdown.net - addonsNet;
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
