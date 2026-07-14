import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/core/components/custom_bottom_sheet.dart';
import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/components/custom_text_field.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/enums/payment_method_enum.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/features/booking/presentation/widgets/payment_method_selection.dart';
import 'package:aqua_go/features/rating/presentation/widgets/tips_biker_info_section.dart';
import 'package:aqua_go/features/rating/presentation/widgets/tip_amount_button.dart';

class PayTipsBottomSheet extends StatefulWidget {
  final BookingResponseModel booking;
  const PayTipsBottomSheet({super.key, required this.booking});

  static Future<void> show(BuildContext context, BookingResponseModel booking) {
    return CustomBottomSheet.show(
      context: context,
      title: LocaleKeys.bookings_send_tip.tr(context: context),
      child: PayTipsBottomSheet(booking: booking),
    );
  }

  @override
  State<PayTipsBottomSheet> createState() => _PayTipsBottomSheetState();
}

class _PayTipsBottomSheetState extends State<PayTipsBottomSheet> {
  double? _selectedAmount;
  bool _isCustomAmountSelected = false;
  final TextEditingController _customAmountController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.creditCard;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _customAmountController.addListener(_onAmountChanged);
    final bool isIOS = !kIsWeb && Platform.isIOS;
    if (isIOS) {
      _selectedPaymentMethod = PaymentMethod.applePay;
    }
  }

  void _onAmountChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _customAmountController.removeListener(_onAmountChanged);
    _customAmountController.dispose();
    super.dispose();
  }

  bool get _isValid {
    if (_isCustomAmountSelected) {
      final text = _customAmountController.text.trim();
      if (text.isEmpty) return false;
      final val = double.tryParse(text);
      return val != null && val > 0;
    }
    return _selectedAmount != null;
  }

  double? get _finalAmount {
    if (_isCustomAmountSelected) {
      return double.tryParse(_customAmountController.text.trim());
    }
    return _selectedAmount;
  }

  void _selectPresetAmount(double amount) {
    setState(() {
      _selectedAmount = amount;
      _isCustomAmountSelected = false;
    });
  }

  void _selectCustomAmount() {
    setState(() {
      _isCustomAmountSelected = true;
      _selectedAmount = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TipsBikerInfoSection(worker: widget.booking.assignedWorker),
        SizedBox(height: height * 0.03),
        _buildAmountSelectionSection(),
        if (_isCustomAmountSelected) ...[
          SizedBox(height: height * 0.02),
          CustomTextField(
            label: LocaleKeys.bookings_custom_amount_label.tr(context: context),
            hint: LocaleKeys.bookings_custom_amount_hint.tr(context: context),
            controller: _customAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
        SizedBox(height: height * 0.03),
        PaymentMethodSelection(
          initialMethod: _selectedPaymentMethod,
          onPaymentMethodChanged: (method) {
            setState(() {
              _selectedPaymentMethod = method;
            });
          },
        ),
        SizedBox(height: height * 0.04),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomButton(
                enabled: _isValid && !_isLoading,
                onPressed: _submitTip,
                text: LocaleKeys.bookings_send.tr(context: context),
              ),
            ),
            SizedBox(width: width * 0.02),
            Expanded(
              flex: 1,
              child: CustomButton(
                onPressed: () => Navigator.pop(context),
                text: LocaleKeys.cancel.tr(context: context),
                color: Colors.transparent,
                textColor: context.colors.primary,
                borderColor: context.colors.borderSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: height * 0.02),
      ],
    );
  }

  Widget _buildAmountSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_tip_amount.tr(context: context),
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TipAmountButton(
                amount: 20.0,
                isSelected: _selectedAmount == 20.0 && !_isCustomAmountSelected,
                onTap: () => _selectPresetAmount(20.0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TipAmountButton(
                amount: 10.0,
                isSelected: _selectedAmount == 10.0 && !_isCustomAmountSelected,
                onTap: () => _selectPresetAmount(10.0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TipAmountButton(
                amount: 5.0,
                isSelected: _selectedAmount == 5.0 && !_isCustomAmountSelected,
                onTap: () => _selectPresetAmount(5.0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Expanded(child: SizedBox.shrink()),
            const SizedBox(width: 10),
            Expanded(
              child: OtherAmountButton(
                isSelected: _isCustomAmountSelected,
                onTap: _selectCustomAmount,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TipAmountButton(
                amount: 50.0,
                isSelected: _selectedAmount == 50.0 && !_isCustomAmountSelected,
                onTap: () => _selectPresetAmount(50.0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submitTip() async {
    if (!_isValid) return;
    setState(() {
      _isLoading = true;
    });

    // Simulate backend payment and tip submitting
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    final amountText = _formatAmountValue(_finalAmount ?? 0.0);
    context.showSuccessSnackBar(
      LocaleKeys.bookings_tip_success_msg.tr(
        context: context,
        args: [amountText],
      ),
    );

    Navigator.pop(context);
  }

  String _formatAmountValue(double amount) {
    return context.isEn
        ? "${amount.toStringAsFixed(2)} SAR"
        : "${amount.toStringAsFixed(2)} ﷼";
  }
}
