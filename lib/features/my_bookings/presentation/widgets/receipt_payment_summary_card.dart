import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';

class ReceiptPaymentSummaryCard extends StatelessWidget {
  final BookingResponseModel booking;

  const ReceiptPaymentSummaryCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    final hasAddons = booking.addOns != null && booking.addOns!.isNotEmpty;
    final breakdown = booking.breakdown;
    final bool showNetVatSummary =
        hasAddons &&
        breakdown != null &&
        (!booking.isCoveredBySubscription || (breakdown.grossMinor ?? 0) != 0) &&
        booking.isFromGift != true;

    return Container(
      padding: EdgeInsets.all(sw(16)),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(sw(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.receipt_payment_summary.tr(context: context),
            style: AppTextStyles.regular12.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: sh(8)),

          // 1. Service Row
          _buildSummaryItemRow(
            context,
            title: booking.title,
            valueWidget: _buildValueWidget(
              context,
              price: _serviceNet(),
              style: AppTextStyles.medium14.copyWith(
                color: context.colors.textPrimary,
              ),
              isCovered: _serviceNet() == 0.0,
            ),
          ),
          _buildDivider(context, sh),

          // 2. Add-on Rows
          if (hasAddons)
            ...booking.addOns!.map((addon) {
              final addonPrice = _addonNet(addon);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSummaryItemRow(
                    context,
                    title: addon.name,
                    valueWidget: _buildValueWidget(
                      context,
                      price: addonPrice,
                      style: AppTextStyles.medium14.copyWith(
                        color: context.colors.textPrimary,
                      ),
                      isCovered: addonPrice == 0.0,
                    ),
                  ),
                  _buildDivider(context, sh),
                ],
              );
            }),

          // 3. Subtotal Row (if showing Net/Vat)
          if (showNetVatSummary) ...[
            _buildSummaryItemRow(
              context,
              title: LocaleKeys.receipt_subtotal.tr(context: context),
              valueWidget: _buildValueWidget(
                context,
                price: breakdown.net,
                style: AppTextStyles.medium14.copyWith(
                  color: context.colors.textPrimary,
                ),
                isCovered: false,
              ),
            ),
            _buildDivider(context, sh),
            _buildSummaryItemRow(
              context,
              title: LocaleKeys.receipt_vat.tr(context: context),
              valueWidget: _buildValueWidget(
                context,
                price: breakdown.vat,
                style: AppTextStyles.medium14.copyWith(
                  color: context.colors.textPrimary,
                ),
                isCovered: false,
              ),
            ),
            _buildDivider(context, sh),
          ],

          // 4. Total Row
          _buildSummaryItemRow(
            context,
            title: LocaleKeys.receipt_total_amount.tr(context: context),
            valueWidget: _buildValueWidget(
              context,
              price: booking.totalAmount,
              style: AppTextStyles.medium16.copyWith(
                color: context.colors.primary,
              ),
              isCovered:
                  booking.isCoveredBySubscription && booking.totalAmount == 0,
            ),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItemRow(
    BuildContext context, {
    required String title,
    required Widget valueWidget,
    bool isTotal = false,
  }) {
    final styleTitle = isTotal
        ? AppTextStyles.medium16.copyWith(color: context.colors.textPrimary)
        : AppTextStyles.regular14.copyWith(color: context.colors.textSecondary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: styleTitle),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildValueWidget(
    BuildContext context, {
    required double price,
    required TextStyle style,
    required bool isCovered,
  }) {
    if (booking.isFromGift == true) {
      return Text(
        LocaleKeys.gifts_paid_via_gift_coupon.tr(context: context),
        style: style,
      );
    }
    if (isCovered || price == 0.0) {
      return Text(
        LocaleKeys.receipt_subscription_package.tr(context: context),
        style: style,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(price.toStringAsFixed(2), style: style),
        const SizedBox(width: 4),
        SvgPicture.asset(
          AppAssets.currency,
          width: 14,
          height: 14,
          colorFilter: ColorFilter.mode(
            style.color ?? context.colors.textPrimary,
            BlendMode.srcIn,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context, double Function(double) sh) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sh(2)),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: context.colors.borderSecondary.withValues(alpha: 0.25),
      ),
    );
  }

  double _addonNet(dynamic addon) {
    final lines = booking.lines ?? const [];
    final matches = lines.where((l) => l.isAddon && l.refId == addon.addonId);
    return matches.isEmpty ? addon.charged : matches.first.net;
  }

  double _serviceNet() {
    final lines = booking.lines ?? const [];
    final serviceLine = lines.where((l) => l.isService).firstOrNull;
    if (serviceLine != null) return serviceLine.net;
    final breakdown = booking.breakdown;
    if (breakdown == null) return 0.0;
    final addonsNet = (booking.addOns ?? const []).fold<double>(
      0.0,
      (sum, a) => sum + _addonNet(a),
    );
    return breakdown.net - addonsNet;
  }
}
