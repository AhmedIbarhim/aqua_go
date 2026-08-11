import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/error_retry_widget.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/config/session/session_state.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/helpers/fetch_user_data_helper.dart';
import '../../../../core/helpers/shimmer_helper.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/saudi_wire_format.dart';
import '../../../../features/auth/data/models/user_model.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/customer_offer_model.dart';
import '../../domain/offer_visibility.dart';
import '../controllers/offers_controller/offers_cubit.dart';
import '../widgets/offer_card.dart';
import 'offer_detail_view.dart';

class OffersView extends StatelessWidget {
  const OffersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: GenericAppBar(
        title: LocaleKeys.offers_title.tr(context: context),
      ),
      body: Column(
        children: [
          const _SignInPrompt(),
          Expanded(child: _fromCubit(context)),
        ],
      ),
    );
  }

  Widget _fromCubit(BuildContext context) {
    return BlocBuilder<OffersCubit, OffersState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: switch (state) {
            OffersLoaded(offers: final loaded) => _Refreshable(
              key: const ValueKey('offers-loaded'),
              child: _list(context, loaded),
            ),

            OffersError() => _Refreshable(
              key: const ValueKey('offers-error'),
              child: _fill(
                ErrorRetryWidget(
                  key: const ValueKey('offers-retry'),
                  errorMessage: LocaleKeys.offers_error.tr(context: context),
                  onRetry: () => context.read<OffersCubit>().getOffers(),
                ),
              ),
            ),
            OffersInitial() || OffersLoading() => _skeleton(context),
          },
        );
      },
    );
  }

  Widget _skeleton(BuildContext context) {
    final cardWidth = context.screenWidth - 32;
    final cardHeight = OfferCard.heightForWidth(context, cardWidth);
    return ListView.separated(
      key: const ValueKey('offers-loading'),
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => ShimmerHelper.homeItemCard(
        context,
        width: double.infinity,
        height: cardHeight,
      ),
    );
  }

  Widget _list(BuildContext context, List<CustomerOfferModel> offers) {
    final sorted = visibleOffers(offers, saudiNow());
    if (sorted.isEmpty) {
      return _fill(const _EmptyState());
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sorted.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),

      itemBuilder: (context, index) => GestureDetector(
        key: ValueKey('offer-card-${sorted[index].id}'),
        onTap: () => openOfferDetail(context, sorted[index]),
        child: OfferCard(offer: sorted[index]),
      ),
    );
  }

  Widget _fill(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        ],
      ),
    );
  }
}

Future<void> openOfferDetail(BuildContext context, CustomerOfferModel offer) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider<OffersCubit>.value(
        value: context.read<OffersCubit>(),
        child: OfferDetailView(offer: offer),
      ),
    ),
  );
}

class _Refreshable extends StatelessWidget {
  const _Refreshable({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<OffersCubit>().getOffers(),
      child: child,
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserModel?>(
      valueListenable: currentUser,
      builder: (context, user, child) {
        if (!FetchUserData.isGuest()) return const SizedBox.shrink();
        return Container(
          key: const ValueKey('offers-sign-in-prompt'),
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.borderSecondary, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  LocaleKeys.offers_sign_in_prompt.tr(context: context),
                  style: AppTextStyles.regular12.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                key: const ValueKey('offers-sign-in-action'),
                onPressed: () => context.pushNamedAndRemoveUntil(Routes.login),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  LocaleKeys.auth_login.tr(context: context),
                  style: AppTextStyles.medium14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppAssets.emptyOffers,
              key: const ValueKey('offers-empty-art'),
            ),
            const SizedBox(height: 40),
            Text(
              LocaleKeys.offers_empty.tr(context: context),
              textAlign: TextAlign.center,
              style: AppTextStyles.regular14.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
