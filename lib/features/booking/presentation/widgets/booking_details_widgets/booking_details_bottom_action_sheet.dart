import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../../core/extentions/context_extentions.dart';
import '../../../../../core/route/routes.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../core/components/custom_button.dart';
import '../../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../../core/route/app_router.dart';
import '../../controllers/booking_cubit.dart';
import '../../controllers/booking_state.dart';
import 'package:aqua_go/features/booking/presentation/widgets/booking_details_widgets/package_addon_payment_bottom_sheet.dart';

class BookingDetailsBottomActionSheet extends StatelessWidget {
  final BookingState bookingState;

  const BookingDetailsBottomActionSheet({
    super.key,
    required this.bookingState,
  });

  bool _requiresPayment(BookingState state) {
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final config = bookingState.flowConfig;

    // In the package flow, when the bundle has more than one included service
    // the customer must pick one before booking. A single-service bundle is
    // auto-selected, so no extra requirement applies there.
    final servicePicked =
        !config.isPackage ||
        bookingState.packageServices.length <= 1 ||
        bookingState.selectedPackageService != null;
    final isComplete =
        bookingState.selectedCar != null &&
        bookingState.selectedDate != null &&
        bookingState.selectedTime != null &&
        servicePicked;

    // For reschedule flow: submit directly from details view
    if (!config.showSummaryStep) {
      return BottomActionSheetContainer(
        child: CustomButton(
          text: LocaleKeys.bookings_confirm_reschedule.tr(context: context),
          enabled: isComplete,
          onPressed: isComplete
              ? () {
                  context.read<BookingCubit>().submitBooking();
                }
              : null,
        ),
      );
    }

    // For service/package flow: show pricing and navigate to summary.
    //
    // PRICE LOCK: the displayed total comes ONLY from the server quote captured
    // at booking initiation (quote.breakdown.gross) — it freezes both the
    // service price and every selected add-on. We do NOT fall back to the live
    // catalog (selectedService.priceDouble + live add-on prices), so admin price
    // edits made mid-session never change this booking's total. No client-side
    // VAT/price math: the amount is the backend-rendered gross.
    final double? lockedTotal = config.showPricingInDetails
        ? bookingState.quote?.breakdown?.gross
        : null;
    // Block "Book now" on the service flow until the price is locked, so we can
    // never navigate to summary on a live (unlocked) amount.
    final bool priceLocked =
        !config.showPricingInDetails || lockedTotal != null;
    final bool canProceed = isComplete && priceLocked;

    return BottomActionSheetContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (config.showPricingInDetails)
            Row(
              children: [
                Text(
                  LocaleKeys.bookings_total.tr(context: context),
                  style: AppTextStyles.regular14.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (lockedTotal == null)
                  Text(
                    LocaleKeys.bookings_calculating_price.tr(context: context),
                    style: AppTextStyles.regular14.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  )
                else ...[
                  Text(
                    lockedTotal.toStringAsFixed(2),
                    style: AppTextStyles.medium24,
                  ),
                  const SizedBox(width: 4),
                  SvgPicture.asset(
                    AppAssets.currency,
                    width: width * 0.06,
                    colorFilter: ColorFilter.mode(
                      context.colors.textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ],
            ),
          CustomButton(
            text: LocaleKeys.bookings_book_now.tr(context: context),
            enabled: canProceed,
            onPressed: canProceed
                ? () async {
                    // For package flow with payable addons, collect payment
                    // method before proceeding to the summary screen.
                    if (_requiresPayment(bookingState)) {
                      final confirmed =
                          await PackageAddonPaymentBottomSheet.show(context);
                      if (!context.mounted) return;
                      // User tapped outside or dragged down — abort navigation.
                      if (!confirmed) return;
                    }
                    if (!context.mounted) return;
                    context.pushNamed(
                      Routes.bookingSummary,
                      arguments: BookingFlowArgs(
                        bookingCubit: context.read<BookingCubit>(),
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
