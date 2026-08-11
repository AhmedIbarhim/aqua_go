import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/components/custom_bottom_sheet.dart';
import '../../../../core/config/payment/payment_sdk_config_service.dart';
import '../../../../core/enums/payment_method_enum.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../booking/data/models/payment_init_model.dart';
import '../../../booking/presentation/views/moyasar_payment_view.dart';
import '../../../home/data/models/package_model.dart';
import '../controllers/subscriptions_controller/subscriptions_cubit.dart';
import '../../data/models/subscription_request_model.dart';
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
      title: LocaleKeys.booking_package_package_details.tr(context: context),
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
  PaymentMethod? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionsCubit, SubscriptionsState>(
      listener: (context, state) {
        if (state is SubscriptionCreated) {
          context.read<SubscriptionsCubit>().getActiveSubscriptions();
          Navigator.pop(context);
          PackageSubscribtionSuccessAlert.show(
            context,
            referenceNumber: state.subscription.referenceNumber,
            subscriptionId: state.subscription.id,
          );
        } else if (state is SubscriptionsError) {
          context.showErrorSnackBar(state.message);
        } else if (state is SubscriptionPaymentCancelled) {
          // User dismissed the Moyasar sheet — stay on the payment step.
        } else if (state is SubscriptionPaymentCreateFailed) {
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
                  onPaymentMethodChanged: (method) {
                    setState(() {
                      _selectedPaymentMethod = method;
                    });
                  },
                  onConfirm: (validContext) {
                    _handleConfirm(validContext);
                  },
                ),
        );
      },
    );
  }

  Future<void> _handleConfirm(BuildContext sheetContext) async {
    final nonce = const Uuid().v4();

    final cubit = sheetContext.read<SubscriptionsCubit>();
    final PaymentInitModel? init = await cubit.initiateSubscriptionPayment(
      packageId: widget.packageModel.id,
    );
    if (init == null || !sheetContext.mounted) return;
    await PaymentSdkConfigService.instance.ensureLoaded();
    if (!sheetContext.mounted) return;

    final paymentMethod = _selectedPaymentMethod ?? PaymentMethod.creditCard;

    final result = await Navigator.of(sheetContext).push<MoyasarPaymentResult>(
      MaterialPageRoute(
        builder: (_) => MoyasarPaymentView(
          args: MoyasarPaymentArgs(
            init: init,
            paymentMethod: paymentMethod,
            description: sheetContext.isAr
                ? 'اشتراك أكوا جو'
                : 'Aqua Go subscription',
          ),
        ),
      ),
    );

    if (!sheetContext.mounted) return;

    switch (result?.status) {
      case MoyasarPaymentStatus.paid:
        await cubit.completeSubscriptionAfterPayment(
          result!.paymentId!,
          SubscriptionRequestModel(
            packageId: widget.packageModel.id,
            paymentMethod: paymentMethod,
            idempotencyNonce: nonce,
          ),
        );
        break;
      case MoyasarPaymentStatus.failed:
        cubit.onSubscriptionPaymentCancelled();
        if (sheetContext.mounted) {
          sheetContext.showErrorSnackBar(
            sheetContext.isAr
                ? 'فشلت عملية الدفع. يرجى المحاولة مرة أخرى.'
                : 'Payment failed. Please try again.',
          );
        }
        break;
      case MoyasarPaymentStatus.cancelled:
      case null:
        cubit.onSubscriptionPaymentCancelled();
        break;
    }
  }
}
