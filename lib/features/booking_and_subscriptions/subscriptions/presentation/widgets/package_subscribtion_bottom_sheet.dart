import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/components/custom_bottom_sheet.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../home/data/models/package_model.dart';
import 'package_subscribtion_details_content.dart';
import 'package_subscribtion_success_alert.dart';
import 'package_subscribtion_payment_content.dart';

enum PackageSubscribtionStep { details, payment }

class PackageSubscribtionBottomSheet extends StatefulWidget {
  final PackageModel packageModel;

  const PackageSubscribtionBottomSheet({super.key, required this.packageModel});

  static Future<T?> show<T>(
    BuildContext context, {
    required PackageModel packageModel,
  }) {
    return CustomBottomSheet.show<T>(
      context: context,
      title: LocaleKeys.booking_package_package_details.tr(),
      child: PackageSubscribtionBottomSheet(packageModel: packageModel),
    );
  }

  @override
  State<PackageSubscribtionBottomSheet> createState() =>
      _PackageSubscribtionBottomSheetState();
}

class _PackageSubscribtionBottomSheetState
    extends State<PackageSubscribtionBottomSheet> {
  PackageSubscribtionStep _currentStep = PackageSubscribtionStep.details;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _currentStep == PackageSubscribtionStep.details
          ? PackageSubscribtionDetailsContent(
              key: const ValueKey('details'),
              packageModel: widget.packageModel,
              onBuy: () {
                setState(() {
                  _currentStep = PackageSubscribtionStep.payment;
                });
              },
            )
          : PackageSubscribtionPaymentContent(
              key: const ValueKey('payment'),
              packageModel: widget.packageModel,
              onConfirm: (validContext) {
                Navigator.pop(context);
                PackageSubscribtionSuccessAlert.show(validContext);
              },
            ),
    );
  }
}
