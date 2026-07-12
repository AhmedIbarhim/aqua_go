import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../generated/locale_keys.g.dart';
import '../controllers/send_gift_cubit.dart';
import '../controllers/send_gift_state.dart';

class SendGiftBottomButton extends StatelessWidget {
  final SendGiftState state;
  final bool isValid;

  const SendGiftBottomButton({
    super.key,
    required this.state,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SendGiftCubit>();
    final width = MediaQuery.sizeOf(context).width;

    // Calculate total price based on service and selected addons
    double totalAmount = 0.0;
    if (state.quote?.breakdown != null) {
      totalAmount = state.quote!.breakdown!.gross;
    } else if (state.selectedService != null) {
      totalAmount += state.selectedService!.priceDouble;
      final selectedAddonsList = state.selectedService!.addons
          .where((addon) => state.selectedAddonIds.contains(addon.id))
          .toList();
      totalAmount += selectedAddonsList.fold<double>(
        0.0,
        (sum, addon) => sum + addon.price,
      );
    }

    return Container(
      padding: EdgeInsets.only(
        left: context.sw(24),
        right: context.sw(24),
        top: context.sh(16),
        bottom: context.sh(24),
      ),
      decoration: BoxDecoration(color: context.colors.screenBG),
      child: SafeArea(
        top: false,
        child: state.step == 0
            ? Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        LocaleKeys.bookings_total.tr(context: context),
                        style: AppTextStyles.regular14.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            totalAmount.toStringAsFixed(2),
                            style: AppTextStyles.medium24.copyWith(
                              fontSize: context.sw(24),
                            ),
                          ),
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                            AppAssets.currency,
                            width: width * 0.05,
                            colorFilter: ColorFilter.mode(
                              context.colors.textPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.4,
                    child: CustomButton(
                      onPressed: isValid
                          ? () {
                              cubit.nextStep();
                            }
                          : null,
                      text: LocaleKeys.proceed.tr(context: context),
                      postWidget: Icon(Icons.arrow_forward),
                      enabled: isValid,
                    ),
                  ),
                ],
              )
            : CustomButton(
                postWidget: state.step == 3 ? null : Icon(Icons.arrow_forward),
                onPressed: isValid
                    ? () {
                        if (state.step < 3) {
                          cubit.nextStep();
                        } else {
                          cubit.submitPurchase();
                        }
                      }
                    : null,
                text: state.step == 3
                    ? LocaleKeys.gifts_confirm_and_pay.tr(context: context)
                    : LocaleKeys.proceed.tr(context: context),
                enabled: isValid,
              ),
      ),
    );
  }
}
