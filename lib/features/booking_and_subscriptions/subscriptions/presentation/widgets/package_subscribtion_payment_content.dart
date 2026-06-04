import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../../core/components/custom_button.dart';
import '../../../../../core/enums/payment_method_enum.dart';
import '../../../../../core/extentions/context_extentions.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../home/data/models/package_model.dart';
import '../../../booking/presentation/widgets/payment_method_selection.dart';

class PackageSubscribtionPaymentContent extends StatefulWidget {
  final PackageModel packageModel;
  final bool isLoading;
  final void Function(BuildContext context) onConfirm;

  const PackageSubscribtionPaymentContent({
    super.key,
    required this.packageModel,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  State<PackageSubscribtionPaymentContent> createState() =>
      _PackageSubscribtionPaymentContentState();
}

class _PackageSubscribtionPaymentContentState
    extends State<PackageSubscribtionPaymentContent> {
  PaymentMethod? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PaymentMethodSelection(
          initialMethod: _selectedMethod,
          onPaymentMethodChanged: (method) {
            setState(() {
              _selectedMethod = method;
            });
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
          value: widget.packageModel.title,
          isTextValue: true,
        ),
        const Divider(height: 24),
        _buildSummaryRow(
          context,
          label: LocaleKeys.bookings_subtotal.tr(),
          value: widget.packageModel.price,
        ),
        const Divider(height: 24),
        _buildSummaryRow(
          context,
          label: LocaleKeys.bookings_vat.tr(),
          value: widget.packageModel.vat,
        ),
        const Divider(height: 24),
        _buildSummaryRow(
          context,
          label: LocaleKeys.bookings_total_amount.tr(),
          value: widget.packageModel.total,
          isTotal: true,
        ),
        const SizedBox(height: 32),
        CustomButton(
          enabled: !widget.isLoading && _selectedMethod != null,
          onPressed: () => widget.onConfirm(context),
          text: LocaleKeys.bookings_confirm_payment.tr(),
          preWidget: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : null,
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
