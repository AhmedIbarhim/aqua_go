import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/custom_bottom_sheet.dart';
import '../../../../../core/extentions/context_extentions.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../home/data/models/package_model.dart';
import '../../controllers/subscriptions_controller/subscriptions_cubit.dart';
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
    final subscriptionsCubit = context.read<SubscriptionsCubit>();
    return CustomBottomSheet.show<T>(
      context: context,
      title: LocaleKeys.booking_package_package_details.tr(),
      child: BlocProvider.value(
        value: subscriptionsCubit,
        child: PackageSubscribtionBottomSheet(packageModel: packageModel),
      ),
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
    return BlocConsumer<SubscriptionsCubit, SubscriptionsState>(
      listener: (context, state) {
        if (state is SubscriptionCreated) {
          context.read<SubscriptionsCubit>().getActiveSubscriptions();
          Navigator.pop(context);
          PackageSubscribtionSuccessAlert.show(context);
        } else if (state is SubscriptionsError) {
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is SubscriptionsLoading;
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
                  isLoading: isLoading,
                  onConfirm: (validContext) {
                    context.read<SubscriptionsCubit>().subscribeToPackage(
                          packageId: widget.packageModel.id,
                        );
                  },
                ),
        );
      },
    );
  }
}
