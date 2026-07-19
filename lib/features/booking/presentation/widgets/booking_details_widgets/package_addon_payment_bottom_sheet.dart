import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';

import '../../../../generated/locale_keys.g.dart';
import '../controllers/booking_cubit.dart';
import '../controllers/booking_state.dart';
import 'payment_method_selection.dart';

class PackageAddonPaymentBottomSheet extends StatelessWidget {
  const PackageAddonPaymentBottomSheet({super.key});

  /// Opens a modal bottom sheet. Returns [true] if the user confirmed a
  /// payment method, or [false]/null if they dismissed without confirming.
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

        // Compute paid addons + package-covered (free) addons from selection.
        // Covered rows are DISPLAY-ONLY at 0.00 (UC-C13 transparency) — they are
        // never summed into [total].
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

        // The subscription wash SERVICE itself is covered by the package.
        // Show the CHOSEN included service (selectedPackageService); fall back to
        // selectedService — which holds the PACKAGE name — only when the bundle
        // has a single service (no picker, so package name is the wash name).
        final coveredService = bookingState.selectedPackageService ??
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

                      // Cost summary. The chosen wash service sits at the top
                      // (covered by the package), followed by covered + paid
                      // add-ons. No section header — the rows are self-describing.
                      if (hasAnyItem) ...[
                        // Covered-by-package wash service (0.00, de-emphasized).
                        if (hasCoveredService)
                          _coveredRow(
                            context: context,
                            width: width,
                            name: serviceName,
                          ),
                        // Covered-by-package add-ons (0.00, de-emphasized).
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
                        // Total reflects only the PAID sum (covered items at
                        // 0.00 are display-only). Shown only when paying.
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

  /// A de-emphasized line for a package-covered item, shown at SAR 0.00 for
  /// full breakdown transparency (UC-C13). Display-only — never summed.
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
