import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../../core/components/custom_button.dart';
import '../../../../../core/extentions/context_extentions.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/app_assets.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../controllers/booking_cubit.dart';
import '../../controllers/booking_state.dart';
import '../booking_summary_widgets/payment_method_selection.dart';

class PackageAddonPaymentBottomSheet extends StatelessWidget {
  const PackageAddonPaymentBottomSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<BookingCubit>(),
        child: const PackageAddonPaymentBottomSheet(),
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, bookingState) {
        final addons = bookingState.selectedService?.addons ?? [];
        final selectedIndices = bookingState.selectedServiceIndices;
        final optionalIds = bookingState.optionalAddonIds;
        final includedIds = bookingState.includedAddonIds;

        final List<({String name, double price})> paidAddons = [];
        final List<({String name})> coveredAddons = [];
        double total = 0;

        for (final idx in selectedIndices) {
          if (idx >= addons.length) continue;
          final addon = addons[idx];
          final id = addon.id ?? '';
          final name = context.isAr
              ? (addon.nameAr ?? addon.nameEn ?? '')
              : (addon.nameEn ?? addon.nameAr ?? '');

          bool isPaid = false;
          if (optionalIds.contains(id)) {
            isPaid = true;
          } else if (includedIds.contains(id)) {
            // included but free quota exhausted
            final remaining = addon.freeQty ?? 0;
            if (remaining <= 0) isPaid = true;
          }

          if (isPaid) {
            paidAddons.add((name: name, price: addon.price));
            total += addon.price;
          } else if (includedIds.contains(id) && (addon.freeQty ?? 0) > 0) {
            // included add-on still inside its free quota → covered by package.
            coveredAddons.add((name: name));
          }
        }

        final coveredService =
            bookingState.selectedPackageService ??
            (bookingState.packageServices.length <= 1
                ? bookingState.selectedService
                : null);
        final serviceName = context.isAr
            ? (coveredService?.rawName?.nameAr ?? '')
            : (coveredService?.rawName?.nameEn ?? '');
        final bool hasCoveredService = serviceName.isNotEmpty;

        final bool hasAnyItem =
            paidAddons.isNotEmpty ||
            coveredAddons.isNotEmpty ||
            hasCoveredService;

        return Container(
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),

          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    width * 0.06,
                    12,
                    width * 0.06,
                    0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: context.colors.borderSecondary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Payment method selection
                      PaymentMethodSelection(
                        initialMethod: bookingState.paymentMethod,
                        onPaymentMethodChanged: (method) {
                          context.read<BookingCubit>().updatePaymentMethod(
                            method,
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      if (hasAnyItem) ...[
                        if (hasCoveredService)
                          _coveredRow(
                            context: context,
                            width: width,
                            name: serviceName,
                          ),
                        ...coveredAddons.map(
                          (item) => _coveredRow(
                            context: context,
                            width: width,
                            name: item.name,
                          ),
                        ),
                        // Paid add-ons.
                        ...paidAddons.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.name,
                                  style: AppTextStyles.regular14.copyWith(
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      item.price.toStringAsFixed(2),
                                      style: AppTextStyles.medium14.copyWith(
                                        color: context.colors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    SvgPicture.asset(
                                      AppAssets.currency,
                                      width: width * 0.04,
                                      colorFilter: ColorFilter.mode(
                                        context.colors.textSecondary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (paidAddons.isNotEmpty) ...[
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                LocaleKeys.bookings_total.tr(context: context),
                                style: AppTextStyles.medium14.copyWith(
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    total.toStringAsFixed(2),
                                    style: AppTextStyles.medium16.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  SvgPicture.asset(
                                    AppAssets.currency,
                                    width: width * 0.04,
                                    colorFilter: ColorFilter.mode(
                                      context.colors.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),

                BottomActionSheetContainer(
                  child: CustomButton(
                    text: LocaleKeys.proceed.tr(context: context),
                    enabled: bookingState.paymentMethod != null,
                    onPressed: bookingState.paymentMethod != null
                        ? () => Navigator.pop(context, true)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _coveredRow({
    required BuildContext context,
    required double width,
    required String name,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.regular14.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            LocaleKeys.bookings_covered_by_package.tr(context: context),
            style: AppTextStyles.regular12.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            (0.0).toStringAsFixed(2),
            style: AppTextStyles.medium14.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          SvgPicture.asset(
            AppAssets.currency,
            width: width * 0.04,
            colorFilter: ColorFilter.mode(
              context.colors.textSecondary,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}
