import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/enums/payment_method_enum.dart';
import '../../../../../core/extentions/context_extentions.dart';
import '../../../../../core/config/payment/payment_sdk_config_service.dart';
import '../../../../../core/components/custom_button.dart';
import '../../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../data/models/payment_init_model.dart';
import '../../controllers/booking_cubit.dart';
import '../../controllers/booking_state.dart';
import '../../views/moyasar_payment_view.dart';

class BookingSummaryBottomActionSheet extends StatelessWidget {
  final BookingState bookingState;
  final String? appliedPromoCode;
  final int? Function() getPointsToApply;

  const BookingSummaryBottomActionSheet({
    super.key,
    required this.bookingState,
    required this.appliedPromoCode,
    required this.getPointsToApply,
  });

  bool _servicePicked(BookingState state) {
    final config = state.flowConfig;
    return !config.isPackage ||
        state.packageServices.length <= 1 ||
        state.selectedPackageService != null;
  }

  bool _hasPayableAddon(BookingState state) {
    if (!state.flowConfig.isPackage) return false;
    final addons = state.selectedService?.addons ?? [];
    final optionalIds = state.optionalAddonIds;
    final includedIds = state.includedAddonIds;
    for (final idx in state.selectedServiceIndices) {
      if (idx >= addons.length) continue;
      final addon = addons[idx];
      final id = addon.id ?? '';
      if (optionalIds.contains(id)) return true;
      if (includedIds.contains(id) && (addon.freeQty ?? 0) <= 0) return true;
    }
    return false;
  }

  double _calculateTotal(BookingState state) {
    final quoteBreakdown = state.quote?.breakdown;
    if (quoteBreakdown != null) {
      return quoteBreakdown.gross;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final config = bookingState.flowConfig;
    final total = _calculateTotal(bookingState);
    final hasPayableAddon = _hasPayableAddon(bookingState);
    final needsPayment =
        config.requiresPaymentMethod || total > 0 || hasPayableAddon;
    final priceLocked = !config.requiresQuote || bookingState.quote != null;
    final servicePicked = _servicePicked(bookingState);
    final isEnabled =
        priceLocked &&
        servicePicked &&
        (needsPayment ? bookingState.paymentMethod != null : true);

    return BottomActionSheetContainer(
      child: CustomButton(
        text: LocaleKeys.bookings_confirm_booking.tr(context: context),
        enabled: isEnabled,
        onPressed: () async {
          final cubit = context.read<BookingCubit>();
          if (!_servicePicked(bookingState)) {
            context.showErrorSnackBar(
              LocaleKeys.bookings_service_selection_required.tr(
                context: context,
              ),
            );
            return;
          }
          if (!needsPayment) {
            cubit.submitBooking();
            return;
          }

          final PaymentInitModel? init;
          if (config.isPackage) {
            init = await cubit.initiateWashAddonPayment();
          } else {
            final existing = cubit.state.quote;
            if (existing != null &&
                DateTime.now().isAfter(existing.expiresAt)) {
              final previousGross = existing.breakdown?.gross;
              final pts = getPointsToApply();
              final refreshed = await cubit.fetchQuote(
                promoCode: appliedPromoCode,
                pointsToApply: pts,
              );
              if (!context.mounted) return;
              if (refreshed == null) return;
              final newGross = refreshed.breakdown?.gross;
              if (previousGross != newGross) {
                context.showErrorSnackBar(
                  LocaleKeys.bookings_price_updated.tr(context: context),
                );
                return;
              }
            }
            final pts = getPointsToApply();
            init = await cubit.initiatePayment(pointsToApply: pts);
          }
          if (init == null || !context.mounted) return;
          await PaymentSdkConfigService.instance.ensureLoaded();
          if (!context.mounted) return;
          final PaymentInitModel resolvedInit = init;
          final result = await Navigator.of(context).push<MoyasarPaymentResult>(
            MaterialPageRoute(
              builder: (_) => MoyasarPaymentView(
                args: MoyasarPaymentArgs(
                  init: resolvedInit,
                  paymentMethod:
                      bookingState.paymentMethod ?? PaymentMethod.creditCard,
                  description: context.isAr ? 'أكوا جو' : 'Aqua Go',
                ),
              ),
            ),
          );
          if (!context.mounted) return;
          switch (result?.status) {
            case MoyasarPaymentStatus.paid:
              await cubit.completeBookingAfterPayment(result!.paymentId!);
              break;
            case MoyasarPaymentStatus.failed:
              cubit.onPaymentCancelled();
              if (context.mounted) {
                context.showErrorSnackBar(
                  context.isAr
                      ? 'فشلت عملية الدفع. يرجى المحاولة مرة أخرى.'
                      : 'Payment failed. Please try again.',
                );
              }
              break;
            case MoyasarPaymentStatus.cancelled:
            case null:
              cubit.onPaymentCancelled();
              break;
          }
        },
      ),
    );
  }
}
