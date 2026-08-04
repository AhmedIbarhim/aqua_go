import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/custom_button.dart';
import '../../../../core/components/custom_loading_indicator.dart';
import '../../../../core/components/error_retry_widget.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../../core/config/session/session_state.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../auth/presentation/controllers/auth_cubit/auth_cubit.dart';
import '../../../my_bookings/data/enums/booking_status_enum.dart';
import '../../../my_bookings/data/repos/my_bookings_repository.dart';
import '../../data/models/policy_model.dart';
import '../controllers/policy_cubit/policy_cubit.dart';
import '../controllers/policy_cubit/policy_state.dart';
import '../widgets/policy_markdown_body.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});
  bool get isGuest => currentUser.value == null;

  @override
  Widget build(BuildContext context) {
    // Read the locale HERE, in build, where depending on an InheritedWidget is
    // legal. Reading it inside a provider's `create:` throws — that callback
    // runs once and can never rebuild, so it must not establish a dependency.
    // The ValueKey is what makes a locale switch re-run `create` and refetch in
    // the new language; without it the cubit would keep serving the old one.
    final localeCode = context.locale.languageCode;
    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.settings_privacy_policy.tr(context: context),
        centerTitle: true,
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => locator<AuthCubit>()),
          BlocProvider(
            key: ValueKey(localeCode),
            create: (_) => locator<PolicyCubit>()
              ..fetchPolicy(type: PolicyType.privacy, locale: localeCode),
          ),
        ],
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
                      BlocBuilder<PolicyCubit, PolicyState>(
                        builder: (context, state) {
                          if (state is PolicyLoading ||
                              state is PolicyInitial) {
                            return const Center(
                              child: CustomLoadingIndicator(size: 100),
                            );
                          } else if (state is PolicyFailure) {
                            return ErrorRetryWidget(
                              errorMessage: state.message,
                              onRetry: () =>
                                  context.read<PolicyCubit>().fetchPolicy(
                                    type: PolicyType.privacy,
                                    locale: localeCode,
                                  ),
                            );
                          } else if (state is PolicySuccess) {
                            return PolicyMarkdownBody(policy: state.policy);
                          }
                          return const SizedBox.shrink();
                        },
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
                              onPressed: () async {
                                context.showLoadingOverlay();
                                final hasActive =
                                    await _checkForActiveBooking();
                                if (!context.mounted) return;
                                context.hideLoadingOverlay();

                                if (hasActive) {
                                  context.showWarningSnackBar(
                                    LocaleKeys
                                        .auth_delete_account_active_bookings_warning
                                        .tr(context: context),
                                  );
                                  return;
                                }

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

  Future<bool> _checkForActiveBooking() async {
    final result = await locator<MyBookingsRepository>().getBookings(limit: 50);
    return result.fold((failure) => false, (response) {
      final activeStatuses = {
        BookingStatus.PENDING,
        BookingStatus.ASSIGNED,
        BookingStatus.ON_THE_WAY,
        BookingStatus.ARRIVED,
        BookingStatus.CANT_FIND_CLIENT,
        BookingStatus.STARTED,
      };
      return response.items.any(
        (booking) => activeStatuses.contains(booking.status),
      );
    });
  }
}
