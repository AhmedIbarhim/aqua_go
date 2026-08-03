import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../controllers/send_gift_cubit.dart';
import '../controllers/send_gift_state.dart';
import '../widgets/choose_gift_step.dart';
import '../widgets/recipient_step.dart';
import '../widgets/customize_step.dart';
import '../widgets/review_and_pay_step.dart';
import '../widgets/send_gift_bottom_button.dart';

class SendGiftView extends StatelessWidget {
  const SendGiftView({super.key});

  bool _isStepValid(SendGiftState state) {
    switch (state.step) {
      case 0:
        return state.selectedService != null;
      case 1:
        final nameValid = state.recipientName.trim().isNotEmpty;
        final phoneValid = RegExp(
          r'^5[0-9]{8}$',
        ).hasMatch(state.recipientPhone);
        return nameValid && phoneValid;
      case 2:
        final themeValid = state.selectedTheme != null;
        if (state.deliveryType == 'SCHEDULED') {
          return themeValid &&
              state.scheduledDate != null &&
              state.scheduledTime != null;
        }
        return themeValid;
      case 3:
        return state.paymentMethod != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SendGiftCubit, SendGiftState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == SendGiftStatus.loading) {
          context.showLoadingOverlay();
        } else {
          context.hideLoadingOverlay();
        }

        if (state.status == SendGiftStatus.success) {
          context.showSuccessSnackBar(
            LocaleKeys.gifts_gift_sent_success.tr(context: context),
          );
          Navigator.pop(context, true);
        } else if (state.status == SendGiftStatus.failure) {
          context.showErrorSnackBar(
            state.errorMessage ??
                LocaleKeys.snackbar_error.tr(context: context),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<SendGiftCubit>();
        final isValid = _isStepValid(state);

        return Scaffold(
          backgroundColor: context.colors.screenBG,
          appBar: GenericAppBar(
            title: context.isAr ? "ارسل هدية" : "Send Gift",
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
              onPressed: () {
                if (state.step > 0) {
                  cubit.previousStep();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          body: state.status == SendGiftStatus.packagesLoading
              ? const Center(child: CustomLoadingIndicator(size: 100))
              : Column(
                  children: [
                    // Outer wizard container with rounded corners and card styling
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.colors.background,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(context.sw(24)),
                            topRight: Radius.circular(context.sw(24)),
                          ),
                        ),
                        child: Column(
                          children: [
                            // --- Steps Progress Indicator ---
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.sw(16),
                                vertical: context.sh(20),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildStepNode(
                                      context,
                                      index: 0,
                                      currentStep: state.step,
                                      label: LocaleKeys.gifts_step_choose_gift
                                          .tr(context: context),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildStepNode(
                                      context,
                                      index: 1,
                                      currentStep: state.step,
                                      label: LocaleKeys.gifts_step_recipient.tr(
                                        context: context,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildStepNode(
                                      context,
                                      index: 2,
                                      currentStep: state.step,
                                      label: LocaleKeys.gifts_step_customize.tr(
                                        context: context,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildStepNode(
                                      context,
                                      index: 3,
                                      currentStep: state.step,
                                      label: LocaleKeys.gifts_step_review_pay
                                          .tr(context: context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: context.sh(12)),

                            // --- Wizard Content ---
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.sw(24),
                                ),
                                child: _getStepWidget(state.step),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SendGiftBottomButton(state: state, isValid: isValid),
                  ],
                ),
        );
      },
    );
  }

  Widget _getStepWidget(int step) {
    switch (step) {
      case 0:
        return const ChooseGiftStep();
      case 1:
        return const RecipientStep();
      case 2:
        return const CustomizeStep();
      case 3:
        return const ReviewAndPayStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepNode(
    BuildContext context, {
    required int index,
    required int currentStep,
    required String label,
  }) {
    final isCompleted = index < currentStep;
    final isActive = index == currentStep;

    return Column(
      children: [
        Row(
          children: [
            if (index > 0)
              Expanded(
                child: Container(
                  height: context.sh(2),
                  color: isCompleted || isActive
                      ? context.colors.primary
                      : context.colors.borderSecondary,
                ),
              )
            else
              const Expanded(child: SizedBox.shrink()),

            Container(
              width: context.sw(20),
              height: context.sw(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? context.colors.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? context.colors.primary
                      : isActive
                      ? context.colors.primary
                      : context.colors.borderSecondary,
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(
                        Icons.check,
                        size: context.sw(12),
                        color: context.colors.themeColor,
                      )
                    : isActive
                    ? Container(
                        width: context.sw(4),
                        height: context.sw(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.primary,
                        ),
                      )
                    : null,
              ),
            ),

            if (index < 3)
              Expanded(
                child: Container(
                  height: context.sh(2),
                  color: currentStep > index
                      ? context.colors.primary
                      : context.colors.borderSecondary,
                ),
              )
            else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
        SizedBox(height: context.sh(8)),
        Text(
          label,
          style: AppTextStyles.regular12.copyWith(
            fontSize: context.sw(12),
            color: isActive
                ? context.colors.primary
                : isCompleted
                ? context.colors.textPrimary
                : context.colors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
