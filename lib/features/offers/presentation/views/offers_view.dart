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

/// The UCC23 offers screen. It ALWAYS renders from the [OffersCubit] above it.
///
/// It used to accept a pre-fetched feed as a route argument, to save a caller
/// a second round-trip. Nothing ever passed one, and the option was actively
/// wrong: a seeded list ignores the cubit, so the A2 promise to return the
/// customer "to a refreshed list" after an offer dies would have re-fetched
/// into a screen that never redrew. Eligibility is evaluated at request time
/// and never cached (BR-OFR-11) — this screen is one of the two places that
/// rule is kept, so it fetches for itself.
class OffersView extends StatelessWidget {
  const OffersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: GenericAppBar(title: LocaleKeys.offers_title.tr(context: context)),
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
        // Crossfades the skeleton straight into the resolved screen instead of
        // swapping it out on a single frame.
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: switch (state) {
            OffersLoaded(offers: final loaded) => _Refreshable(
                key: const ValueKey('offers-loaded'),
                child: _list(context, loaded),
              ),
            // UCC23 A6 — an outage gets a RETRY state, never an empty list, so
            // "the promotions service is down" cannot be read as "there are no
            // offers". Pull-to-refresh stays as the second affordance, but it
            // is not discoverable on its own, so the button is the primary one.
            OffersError() => _Refreshable(
                key: const ValueKey('offers-error'),
                child: _fill(
                  // The house error+retry component — the same one 11 other
                  // screens use. Pull-to-refresh stays as the second affordance,
                  // but it is not discoverable on its own, so the button is the
                  // primary one.
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
    // The skeleton stands at the real card's height so the handoff doesn't
    // shift the page under the reader.
    final cardHeight = OfferCard.heightFor(context);
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
    // UCC23 step 2 — expiry is a FILTER, not just a sort key. A feed held on
    // screen goes stale in the customer's hand, and a dead card at the bottom
    // of the list is a deal they will be refused at apply time.
    final sorted = visibleOffers(offers, saudiNow());
    if (sorted.isEmpty) {
      // UCC23 A1 — "an illustration and the line". The illustration is what
      // makes an empty list read as a finished state rather than as a screen
      // that failed to draw; A6 is the separate state for an actual outage.
      return _fill(const _EmptyState());
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sorted.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      // Flat, like every other list in the product (`my_bookings_view`,
      // `my_cars_view`, `packages_list_view`, `notification_view`). No list here
      // staggers its items, and this one is not the place to invent a second
      // motion language.
      itemBuilder: (context, index) => GestureDetector(
        key: ValueKey('offer-card-${sorted[index].id}'),
        onTap: () => openOfferDetail(context, sorted[index]),
        child: OfferCard(offer: sorted[index]),
      ),
    );
  }

  /// A single centred body that still fills — and scrolls — the whole screen,
  /// so it sits at the optical centre on every size and pull-to-refresh keeps
  /// working.
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

/// Opens the detail screen for [offer], carrying the caller's [OffersCubit]
/// down with it.
///
/// The cubit has to travel: UCC23 A2 re-validates on the primary action and,
/// when the offer has gone, "returns the customer to a refreshed list". The
/// list to refresh is the one they came FROM — the offers screen or the home
/// rail — and a pushed route is a sibling of the route that provides the cubit,
/// not a descendant, so without this the detail screen could not reach it.
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

/// UCC23 A4 — "a sign-in prompt states that more offers may be available once
/// signed in".
///
/// A guest is served the anonymous subset: the server can evaluate BR-OFR-01,
/// -02 and -03 for them and nothing else, so every offer gated on usage history,
/// registration date, first booking, saved-address zone or subscription count is
/// simply missing from their feed. Without this line an empty or short list
/// reads as "Aqua Go has no offers", which is the same misreading A6 exists to
/// prevent for outages.
///
/// It renders for a guest on EVERY state of the screen, the empty one most of
/// all. It never says which offers are missing — UCC23 forbids revealing why an
/// offer was withheld, and "you are not signed in" is a fact about the viewer,
/// not about any particular campaign.
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

/// UCC23 A1 — "an illustration and the line", and deliberately NO action: an
/// empty feed is a finished state, not something the customer can fix.
///
/// Same shape as every other empty state in the app — a bare
/// `SvgPicture.asset` at its natural size, 40pt of air, then the line
/// (`EmptyCarsWidget`, `EmptyBookingsWidget`).
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
