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
import '../../controllers/booking_payment_cubit.dart';
import '../../controllers/booking_pricing_cubit.dart';
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
        bookingState.selectedSlotStart != null &&
        servicePicked;

    // For reschedule flow: submit directly from details view
    if (!config.showSummaryStep) {
      return BottomActionSheetContainer(
        child: CustomButton(
          text: LocaleKeys.bookings_confirm_reschedule.tr(context: context),
          enabled: isComplete,
          onPressed: isComplete
              ? () {
                  context.read<BookingPaymentCubit>().submitBooking();
                }
              : null,
        ),
      );
    }

    final quote = context.select(
      (BookingPricingCubit cubit) => cubit.state.quote,
    );
    final double? lockedTotal = config.showPricingInDetails
        ? quote?.breakdown?.gross
        : null;

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
                    if (_requiresPayment(bookingState)) {
                      final confirmed =
                          await PackageAddonPaymentBottomSheet.show(context);
                      if (!context.mounted) return;
                      if (!confirmed) return;
                    }
                    if (!context.mounted) return;
                    context.pushNamed(
                      Routes.bookingSummary,
                      arguments: BookingFlowArgs.of(context),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
