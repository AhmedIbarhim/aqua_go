import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/custom_button.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../../core/config/session/session_state.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../auth/presentation/controllers/auth_cubit/auth_cubit.dart';
import 'local_texts/privacy_policy_texts_ar.dart';
import 'local_texts/privacy_policy_texts_en.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});
  bool get isGuest => currentUser.value == null;

  @override
  Widget build(BuildContext context) {
    final texts = context.isAr ? privacyPolicyTextsAr : privacyPolicyTextsEn;

    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: texts.title,
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) => locator<AuthCubit>(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.colors.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        texts.intro,
                        style: AppTextStyles.regular14.copyWith(
                          color: context.colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      _buildDivider(context),
                      ...List.generate(texts.sections.length, (index) {
                        final section = texts.sections[index];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.title,
                              style: AppTextStyles.medium16.copyWith(
                                color: context.colors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              section.content,
                              style: AppTextStyles.regular16.copyWith(
                                color: context.colors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            if (index < texts.sections.length - 1) _buildDivider(context),
                          ],
                        );
                      }),
                      const SizedBox(height: 24),
                      Text(
                        texts.footer,
                        style: AppTextStyles.medium16.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 48),
                      if (!isGuest)
                        BlocConsumer<AuthCubit, AuthState>(
                          listener: (context, state) {
                            if (state is DeleteAccountLoading) {
                              context.showLoadingOverlay();
                            } else {
                              context.hideLoadingOverlay();
                            }

                            if (state is DeleteAccountError) {
                              context.showErrorSnackBar(state.message);
                            }
                            if (state is DeleteAccountSuccess) {
                              context.showWarningSnackBar(
                                LocaleKeys.auth_delete_account_success.tr(
                                  context: context,
                                ),
                              );
                              context.pushNamedAndRemoveUntil(
                                Routes.onboarding,
                              );
                            }
                          },
                          builder: (context, state) {
                            return CustomButton(
                              text: LocaleKeys.auth_delete_account.tr(
                                context: context,
                              ),
                              color: context.colors.error,
                              textColor: lightAppColors.themeColor,
                              borderColor: context.colors.error,
                              onPressed: () {
                                context.showWarningAlert(
                                  title: LocaleKeys.auth_delete_account.tr(
                                    context: context,
                                  ),
                                  message: LocaleKeys
                                      .auth_delete_account_confirmation
                                      .tr(context: context),
                                  onPrimaryPressed: () {
                                    context.read<AuthCubit>().deleteAccount();
                                  },
                                );
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        color: context.colors.borderSecondary.withAlpha(50),
        thickness: 1,
      ),
    );
  }
}
