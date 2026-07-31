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

class OffersCarouselView extends StatelessWidget {
  const OffersCarouselView({super.key});

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

  void _handleOfferTap(BuildContext context, CustomerOfferModel offer) {
    openOfferDetail(context, offer);
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.offers, required this.onTap});

  final List<CustomerOfferModel> offers;
  final void Function(BuildContext, CustomerOfferModel) onTap;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: height * 0.21,
      child: CarouselView(
        itemExtent: height * 0.4,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: (index) => onTap(context, offers[index]),
        children: offers.map((offer) {
          return OfferCard(
            key: ValueKey('offer-card-${offer.id}'),
            offer: offer,
          );
        }).toList(),
      ),
    );
  }
}

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
