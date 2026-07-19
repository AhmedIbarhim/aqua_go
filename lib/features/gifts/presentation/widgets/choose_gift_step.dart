import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../controllers/send_gift_cubit.dart';
import '../controllers/send_gift_state.dart';
import '../../../booking/presentation/widgets/booking_details_widgets/add_ons_grid.dart';
import 'gift_service_card.dart';

class ChooseGiftStep extends StatelessWidget {
  const ChooseGiftStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SendGiftCubit, SendGiftState>(
      builder: (context, state) {
        if (state.services.isEmpty) {
          return SizedBox(
            height: context.sh(350),
            child: Center(
              child: Text(
                "No services available.",
                style: AppTextStyles.regular16.copyWith(
                  fontSize: context.sw(16),
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          );
        }

        final selectedService = state.selectedService ?? state.services.first;
        final optionalAddons = selectedService.addons;

        final selectedIndices = <int>{};
        for (int i = 0; i < optionalAddons.length; i++) {
          if (state.selectedAddonIds.contains(optionalAddons[i].id)) {
            selectedIndices.add(i);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Title ---
            Text(
              LocaleKeys.gifts_choose_service_to_send.tr(context: context),
              style: AppTextStyles.bold16.copyWith(
                fontSize: context.sw(16),
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: context.sh(12)),

            // --- Vertical Services List ---
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.services.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: context.sh(12)),
              itemBuilder: (context, index) {
                final service = state.services[index];
                final isSelected = selectedService.id == service.id;

                return GiftServiceCard(
                  service: service,
                  isSelected: isSelected,
                  onTap: () {
                    context.read<SendGiftCubit>().selectService(service);
                  },
                );
              },
            ),

            if (optionalAddons.isNotEmpty) ...[
              SizedBox(height: context.sh(24)),
              Text(
                LocaleKeys.bookings_additional_services.tr(context: context),
                style: AppTextStyles.bold16.copyWith(
                  fontSize: context.sw(16),
                  color: context.colors.textPrimary,
                ),
              ),
              SizedBox(height: context.sh(12)),

              // --- AddOns Grid ---
              AddOnsGrid(
                addons: optionalAddons,
                selectedIndices: selectedIndices,
                onServiceToggled: (index) {
                  final addonId = optionalAddons[index].id;
                  if (addonId != null) {
                    context.read<SendGiftCubit>().toggleAddon(addonId);
                  }
                },
              ),
            ],
            SizedBox(height: context.sh(24)),
          ],
        );
      },
    );
  }
}
