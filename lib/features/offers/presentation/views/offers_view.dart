import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/helpers/shimmer_helper.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/customer_offer_model.dart';
import '../controllers/offers_controller/offers_cubit.dart';
import '../widgets/offer_card.dart';
import '../widgets/offer_motion.dart';
import 'offer_detail_view.dart';

/// Optional route arguments for [Routes.offers]. A caller that ALREADY holds
/// the eligible feed can pass it to skip a second round-trip; the home rail's
/// "View more" pushes bare and the screen self-fetches instead.
class OffersArgs {
  final List<CustomerOfferModel> offers;
  OffersArgs({required this.offers});
}

class OffersView extends StatelessWidget {
  const OffersView({super.key, this.offers});

  /// Non-null -> render this list verbatim. Null -> render whatever the
  /// [OffersCubit] provided above this widget emits (the router kicks off
  /// `getOffers()` in that case).
  final List<CustomerOfferModel>? offers;

  /// Card height the skeleton stands in for, as a fraction of the screen. Kept
  /// close to the real card so the handoff doesn't shift the page.
  static const double _cardHeightFactor = 0.3;

  @override
  Widget build(BuildContext context) {
    final seeded = offers;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: GenericAppBar(title: LocaleKeys.offers_title.tr(context: context)),
      body: seeded != null ? _list(context, seeded) : _fromCubit(context),
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
            OffersError() => _Refreshable(
                key: const ValueKey('offers-error'),
                // Pull-to-retry is the only recovery path this screen offers,
                // so the error state has to stay scrollable.
                child: _fill(LocaleKeys.offers_error.tr(context: context)),
              ),
            OffersInitial() || OffersLoading() => _skeleton(context),
          },
        );
      },
    );
  }

  Widget _skeleton(BuildContext context) {
    final cardHeight = MediaQuery.sizeOf(context).height * _cardHeightFactor;
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
    if (offers.isEmpty) {
      return _fill(LocaleKeys.offers_empty.tr(context: context));
    }
    // Defensive: the API already returns endsAt ASC, but this screen owns the
    // ordering the design pins, so it re-sorts locally.
    final sorted = [...offers]..sort((a, b) => a.endsAt.compareTo(b.endsAt));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sorted.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final card = GestureDetector(
          onTap: () => _openDetail(context, sorted[index]),
          child: OfferCard(offer: sorted[index], atHome: false),
        );
        // Only the opening screenful is staggered; items further down are built
        // lazily on scroll, where a delay would read as a dropped card.
        if (index >= OfferEntrance.maxStaggerSteps) return card;
        return OfferEntrance(index: index, child: card);
      },
    );
  }

  /// A single centred message that still fills — and scrolls — the whole body,
  /// so it sits at the optical centre on every screen size and pull-to-refresh
  /// keeps working.
  Widget _fill(String text) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: _Message(text: text),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, CustomerOfferModel offer) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OfferDetailView(offer: offer)),
    );
  }
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

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
