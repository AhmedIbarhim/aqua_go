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
        (!booking.isCoveredBySubscription ||
            (breakdown.grossMinor ?? 0) != 0) &&
        booking.isFromGift != true;
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
              if (showNetVatSummary || booking.isFromGift == true)
                _buildSummaryRow(
                  context,
                  title: LocaleKeys.bookings_service_price.tr(context: context),
                  value: booking.isFromGift == true
                      ? LocaleKeys.gifts_paid_via_gift_coupon.tr(
                          context: context,
                        )
                      : _serviceNet() == 0.0
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
                    value: booking.isFromGift == true
                        ? LocaleKeys.gifts_paid_via_gift_coupon.tr(
                            context: context,
                          )
                        : addonPrice == 0.0
                        ? LocaleKeys.bookings_covered_by_subscription.tr(
                            context: context,
                          )
                        : '${addonPrice.toStringAsFixed(2)} $currency',
                    icon: AppAssets.terms,
                  );
                }),
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
              if (booking.isFromGift == true) _buildTotalDivider(context),
              // Exactly ONE grand total, last, VAT-inclusive (gross).
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

  Widget _buildSummaryRow(
    BuildContext context, {
    required String title,
    required String value,
    required String icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                context.colors.textTertiary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.regular14.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.contentSecondaryLight,
          ),
        ),
      ],
    );
  }
}
