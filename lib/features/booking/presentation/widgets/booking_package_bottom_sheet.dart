import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/components/custom_bottom_sheet.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../home/data/models/package_model.dart';
import 'booking_package_details_content.dart';
import 'booking_package_success_alert.dart';
import 'booking_package_payment_content.dart';

enum PackageBookingStep { details, payment }

class BookingPackageBottomSheet extends StatefulWidget {
  final PackageModel packageModel;

  const BookingPackageBottomSheet({super.key, required this.packageModel});

  static Future<T?> show<T>(
    BuildContext context, {
    required PackageModel packageModel,
  }) {
    return CustomBottomSheet.show<T>(
      context: context,
      title: LocaleKeys.booking_package_package_details.tr(),
      child: BookingPackageBottomSheet(packageModel: packageModel),
    );
  }

  @override
  State<BookingPackageBottomSheet> createState() =>
      _BookingPackageBottomSheetState();
}

class _BookingPackageBottomSheetState extends State<BookingPackageBottomSheet> {
  PackageBookingStep _currentStep = PackageBookingStep.details;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _currentStep == PackageBookingStep.details
          ? BookingPackageDetailsContent(
              key: const ValueKey('details'),
              packageModel: widget.packageModel,
              onBuy: () {
                setState(() {
                  _currentStep = PackageBookingStep.payment;
                });
              },
            )
          : BookingPackagePaymentContent(
              key: const ValueKey('payment'),
              packageModel: widget.packageModel,
              onConfirm: (validContext) {
                Navigator.pop(context);
                BookingPackageSuccessAlert.show(validContext);
              },
            ),
    );
  }
}
