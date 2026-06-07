import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/extentions/context_extentions.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../../core/components/custom_radio_widget.dart';
import '../../../../../core/enums/payment_method_enum.dart';

class PaymentMethodSelection extends StatefulWidget {
  final Function(PaymentMethod) onPaymentMethodChanged;
  final PaymentMethod? initialMethod;

  const PaymentMethodSelection({
    super.key,
    required this.onPaymentMethodChanged,
    this.initialMethod,
  });

  @override
  State<PaymentMethodSelection> createState() => _PaymentMethodSelectionState();
}

class _PaymentMethodSelectionState extends State<PaymentMethodSelection> {
  PaymentMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.initialMethod;
  }

  @override
  void didUpdateWidget(covariant PaymentMethodSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMethod != oldWidget.initialMethod) {
      setState(() {
        _selectedMethod = widget.initialMethod;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_pay_through.tr(),
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildPaymentMethodItem(
          context,
          method: PaymentMethod.applePay,
          title: LocaleKeys.bookings_apple_pay.tr(),
          iconPaths: [AppAssets.applePay],
        ),
        const SizedBox(height: 8),
        _buildPaymentMethodItem(
          context,
          method: PaymentMethod.creditCard,
          title: LocaleKeys.bookings_credit_card.tr(),
          iconPaths: [
            AppAssets.visaPay,
            AppAssets.mastercardPay,
            AppAssets.madaPay,
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodItem(
    BuildContext context, {
    required PaymentMethod method,
    required String title,
    required List<String> iconPaths,
  }) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
        widget.onPaymentMethodChanged(method);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.brandHover
              : context.colors.themeColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.borderSecondary,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Row(
                children: [
                  Text(
                    title,
                    style: AppTextStyles.medium14.copyWith(
                      color: isSelected
                          ? context.colors.textPrimary
                          : context.colors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 4,
                        children: iconPaths
                            .map(
                              (path) => ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.asset(
                                  path,
                                  height: 22,
                                  width: 32,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            CustomRadioWidget(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}
