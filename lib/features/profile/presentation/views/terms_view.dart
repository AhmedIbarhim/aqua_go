import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/custom_loading_indicator.dart';
import '../../../../core/components/error_retry_widget.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../data/models/policy_model.dart';
import '../controllers/policy_cubit/policy_cubit.dart';
import '../controllers/policy_cubit/policy_state.dart';
import '../widgets/policy_markdown_body.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    // See PrivacyPolicyView: the locale must be read here, not inside `create:`.
    final localeCode = context.locale.languageCode;
    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.settings_terms_and_conditions.tr(context: context),
        centerTitle: true,
      ),
      body: BlocProvider(
        key: ValueKey(localeCode),
        create: (_) => locator<PolicyCubit>()
          ..fetchPolicy(type: PolicyType.tos, locale: localeCode),
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
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: BlocBuilder<PolicyCubit, PolicyState>(
                    builder: (context, state) {
                      if (state is PolicyLoading || state is PolicyInitial) {
                        return const Center(
                          child: CustomLoadingIndicator(size: 100),
                        );
                      } else if (state is PolicyFailure) {
                        return ErrorRetryWidget(
                          errorMessage: state.message,
                          onRetry: () => context.read<PolicyCubit>().fetchPolicy(
                            type: PolicyType.tos,
                            locale: localeCode,
                          ),
                        );
                      } else if (state is PolicySuccess) {
                        return PolicyMarkdownBody(policy: state.policy);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
