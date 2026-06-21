import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:moyasar/moyasar.dart' as moyasar;

import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/config/payment/moyasar_config.dart';
import 'package:aqua_go/core/enums/payment_method_enum.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/features/booking/data/models/payment_init_model.dart';

/// Arguments for the on-device Moyasar purchase step (pay-before-create).
class MoyasarPaymentArgs {
  final PaymentInitModel init;

  /// The chosen surface — card on both platforms, Apple Pay on iOS only.
  final PaymentMethod paymentMethod;

  /// Human-readable description tagged on the Moyasar payment.
  final String description;

  MoyasarPaymentArgs({
    required this.init,
    required this.paymentMethod,
    required this.description,
  });
}

/// Renders the Moyasar `CreditCard` / `ApplePay` widget for a single
/// purchase. On a verified `paid` result it pops with the Moyasar payment
/// id (a `String`); on cancel/dismiss it pops with `null`. The backend then
/// verifies + creates the booking (spec §4.2). 3DS is managed in-app by the
/// SDK; card data goes device→Moyasar (SAQ A preserved).
class MoyasarPaymentView extends StatelessWidget {
  final MoyasarPaymentArgs args;

  const MoyasarPaymentView({super.key, required this.args});

  moyasar.PaymentConfig _buildConfig() {
    return moyasar.PaymentConfig(
      publishableApiKey: MoyasarConfig.publishableApiKey,
      amount: args.init.amountMinor,
      currency: args.init.currency,
      description: args.description,
      metadata: args.init.metadata,
      givenID: args.init.givenId,
      applePay: moyasar.ApplePayConfig(
        merchantId: MoyasarConfig.applePayMerchantId,
        label: MoyasarConfig.applePayLabel,
        manual: false,
        saveCard: false,
      ),
    );
  }

  void _onPaymentResult(BuildContext context, dynamic result) {
    if (result is moyasar.PaymentResponse) {
      switch (result.status) {
        case moyasar.PaymentStatus.paid:
          // Return the verified-paid payment id to the booking flow.
          Navigator.of(context).pop(result.id);
          break;
        case moyasar.PaymentStatus.failed:
          context.showErrorSnackBar(
            context.isAr
                ? 'فشلت عملية الدفع. يرجى المحاولة مرة أخرى.'
                : 'Payment failed. Please try again.',
          );
          break;
        case moyasar.PaymentStatus.initiated:
        case moyasar.PaymentStatus.authorized:
        case moyasar.PaymentStatus.captured:
          // 3DS / interim states handled in-app by the SDK; no action here.
          break;
      }
    } else if (result is moyasar.PaymentCanceledError) {
      Navigator.of(context).pop(null);
    } else {
      context.showErrorSnackBar(
        context.isAr
            ? 'تعذّر إتمام عملية الدفع.'
            : 'Could not complete the payment.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!MoyasarConfig.isConfigured) {
      return Scaffold(
        appBar: const GenericAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              context.isAr
                  ? 'إعدادات الدفع غير مكتملة.'
                  : 'Payment is not configured.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final config = _buildConfig();
    final bool showApplePay =
        args.paymentMethod == PaymentMethod.applePay &&
        !kIsWeb &&
        Platform.isIOS;

    return Scaffold(
      appBar: const GenericAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showApplePay)
                moyasar.ApplePay(
                  config: config,
                  onPaymentResult: (result) =>
                      _onPaymentResult(context, result),
                )
              else
                moyasar.CreditCard(
                  config: config,
                  onPaymentResult: (result) =>
                      _onPaymentResult(context, result),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
