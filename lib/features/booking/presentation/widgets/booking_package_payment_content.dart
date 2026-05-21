import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../home/data/models/package_model.dart';
import 'payment_method_selection.dart';


class BookingPackagePaymentContent extends StatelessWidget {
  final PackageModel packageModel;
  final void Function(BuildContext context) onConfirm;

  const BookingPackagePaymentContent({
    super.key,
    required this.packageModel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PaymentMethodSelection(
          onPaymentMethodChanged: (method) {
            // Handle payment method change if needed
          },
        ),
        const SizedBox(height: 24),
        Text(
          LocaleKeys.bookings_payment_summary.tr(),
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildSummaryRow(
          context,
          label: LocaleKeys.bookings_package_name.tr(),
          value: packageModel.title,
          isTextValue: true,
        ),
        const Divider(height: 24),
        _buildSummaryRow(
          context,
          label: LocaleKeys.bookings_subtotal.tr(),
          value: packageModel.price,
        ),
        const Divider(height: 24),
        _buildSummaryRow(
          context,
          label: LocaleKeys.bookings_vat.tr(),
          value: packageModel.vat,
        ),
        const Divider(height: 24),
        _buildSummaryRow(
          context,
          label: LocaleKeys.bookings_total_amount.tr(),
          value: packageModel.total,
          isTotal: true,
        ),
        const SizedBox(height: 32),
        CustomButton(
          onPressed: () => onConfirm(context),
          text: LocaleKeys.bookings_confirm_payment.tr(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isTotal = false,
    bool isTextValue = false,
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
              value,
              style:
                  (isTotal ? AppTextStyles.medium16 : AppTextStyles.regular16)
                      .copyWith(
                        color: isTotal
                            ? context.colors.textPrimary
                            : context.colors.textSecondary,
                      ),
            ),
            if (!isTextValue) ...[
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
          ],
        ),
      ],
    );
  }
}
