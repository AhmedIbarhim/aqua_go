import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/helpers/shimmer_helper.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/saudi_wire_format.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../offers/data/models/customer_offer_model.dart';
import '../../../offers/domain/offer_visibility.dart';
import '../../../offers/presentation/controllers/offers_controller/offers_cubit.dart';
import '../../../offers/presentation/views/offers_view.dart';
import '../../../offers/presentation/widgets/offer_card.dart';

/// Home "Best Offers" rail. Reads the live UCC23 eligible-offers feed from the
/// [OffersCubit] provided by HomeView.
///
/// Three states, deliberately distinct (UCC23 A1 / A6):
/// * loading — the header plus a skeleton;
/// * error — the header plus a RETRY affordance. The rail used to hide itself
///   on failure too, on the reasoning that offers are promotional and never
///   load-bearing. A6 overrides that: "the screen shows a retry state rather
///   than an empty list, so an outage is not mistaken for 'no offers'". A
///   silently-absent rail is precisely that mistake, and it is invisible to the
///   customer, so they cannot even pull to refresh it back;
/// * genuinely empty — nothing at all. There is no promotion to advertise and
///   home is not the offers screen, so an empty state here would be noise. This
///   is the ONE case where hiding is right, and it is now the only one.
class OffersListView extends StatelessWidget {
  const OffersListView({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return BlocBuilder<OffersCubit, OffersState>(
      builder: (context, state) {
        if (state is OffersInitial || state is OffersLoading) {
          return Column(
            children: [
              const _Header(showViewMore: false),
              SizedBox(height: height * 0.012),
              // The skeleton stands at the card's own height, so the handoff
              // from loading to loaded does not jump the page.
              ShimmerHelper.offers(height: OfferCard.heightFor(context)),
            ],
          );
        }

        if (state is OffersError) {
          return Column(
            children: [
              const _Header(showViewMore: false),
              SizedBox(height: height * 0.012),
              const _RailRetry(),
            ],
          );
        }

        // UCC23 step 2 — the rail sits on the home screen for as long as the
        // customer keeps the app open, so an offer that closed since the fetch
        // has to drop out rather than linger at the end of the row.
        final List<CustomerOfferModel> offers = state is OffersLoaded
            ? visibleOffers(state.offers, saudiNow())
            : const <CustomerOfferModel>[];

        if (offers.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            const _Header(showViewMore: true),
            SizedBox(height: height * 0.012),
            _Rail(offers: offers, onTap: _handleOfferTap),
          ],
        );
      },
    );
  }

  /// UCC23 step 6 — "customer taps an offer to open its detail view". Every
  /// card, of either type, opens the offer the customer actually touched.
  ///
  /// It used to send a promo offer to the unfiltered offers LIST, which loses
  /// the tap: the customer picked one card and got back the whole set, with the
  /// one they wanted somewhere in it. A package offer jumped straight past the
  /// detail view into the subscription catalogue, skipping the terms and the
  /// A2 re-validation the primary action performs. Both now go through the
  /// detail view, which owns the type-specific primary action.
  void _handleOfferTap(BuildContext context, CustomerOfferModel offer) {
    openOfferDetail(context, offer);
  }
}

/// The horizontal strip of offer cards.
///
/// Now that a card is its banner and nothing else, the rail is the banner
/// carousel: the same `CarouselSlider` geometry `HomeBannersCarosal` uses —
/// its height fractions, its viewport fraction, its centre-page enlargement —
/// so an offer sits at the same scale, in the same rhythm, as the banner strip
/// higher up the same screen. It used to be a `SingleChildScrollView` of
/// 0.72-width cards sized by their text, which no longer has anything to
/// measure.
///
/// Two deliberate departures from the banner strip: no autoplay and no dots.
/// Offers are a browse list with a "view more" beside them, and a card that
/// rotates out from under a reader's thumb takes the tap with it.
class _Rail extends StatelessWidget {
  const _Rail({required this.offers, required this.onTap});

  final List<CustomerOfferModel> offers;
  final void Function(BuildContext, CustomerOfferModel) onTap;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: offers.length,
      itemBuilder: (context, index, realIndex) => GestureDetector(
        // Keyed by the offer, not the slot: an infinite carousel builds the
        // same offer on either side of the one in the middle, so a positional
        // handle picks whichever copy the viewport happened to lay out first.
        key: ValueKey('offer-card-${offers[index].id}'),
        onTap: () => onTap(context, offers[index]),
        child: OfferCard(offer: offers[index]),
      ),
      options: CarouselOptions(
        height: OfferCard.heightFor(context),
        viewportFraction: context.isTablet ? 0.6 : 0.75,
        initialPage: 0,
        // A single eligible offer has nothing to wrap around to, and looping it
        // against itself only offers the customer a scroll that goes nowhere.
        enableInfiniteScroll: offers.length > 1,
        enlargeCenterPage: true,
        enlargeFactor: 0.2,
        scrollDirection: Axis.horizontal,
        enlargeStrategy: CenterPageEnlargeStrategy.scale,
      ),
    );
  }
}

/// UCC23 A6 — the rail's retry state. Deliberately the same shape as a card so
/// the row does not collapse and re-expand when the retry succeeds.
class _RailRetry extends StatelessWidget {
  const _RailRetry();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.cardBackGround,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.borderSecondary, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                LocaleKeys.offers_error.tr(context: context),
                style: AppTextStyles.regular12.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              key: const ValueKey('home-offers-retry'),
              onPressed: () => context.read<OffersCubit>().getOffers(),
              style: TextButton.styleFrom(
                foregroundColor: context.colors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                LocaleKeys.retry.tr(context: context),
                style: AppTextStyles.medium14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.showViewMore});

  final bool showViewMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            LocaleKeys.home_best_offers.tr(context: context),
            style: !context.isTablet
                ? AppTextStyles.bold16
                : AppTextStyles.bold18,
          ),
          if (showViewMore)
            GestureDetector(
              onTap: () => context.pushNamed(Routes.offers),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    LocaleKeys.home_view_more.tr(context: context),
                    style: AppTextStyles.regular12.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: context.colors.primary,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
