import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/helpers/shimmer_helper.dart';
import '../../../../core/route/app_router.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../offers/data/models/customer_offer_model.dart';
import '../../../offers/domain/offer_visibility.dart';
import '../../../offers/presentation/controllers/offers_controller/offers_cubit.dart';
import '../../../offers/presentation/widgets/offer_card.dart';

/// Home "Best Offers" rail. Reads the live UCC23 eligible-offers feed from the
/// [OffersCubit] provided by HomeView. A failed or empty feed hides the rail
/// rather than breaking home — offers are promotional, never load-bearing.
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
              ShimmerHelper.offers(height: height * 0.21),
            ],
          );
        }

        // UCC23 step 2 — the rail sits on the home screen for as long as the
        // customer keeps the app open, so an offer that closed since the fetch
        // has to drop out rather than linger at the end of the row.
        final List<CustomerOfferModel> offers = state is OffersLoaded
            ? visibleOffers(state.offers, DateTime.now())
            : const <CustomerOfferModel>[];

        if (offers.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            const _Header(showViewMore: true),
            SizedBox(height: height * 0.012),
            SizedBox(
              height: height * 0.21,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: offers.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => _handleOfferTap(context, offers[index]),
                  child: OfferCard(offer: offers[index]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// A PACKAGE offer opens that package directly; anything else opens the full
  /// offers screen, which renders the promo code and its terms.
  void _handleOfferTap(BuildContext context, CustomerOfferModel offer) {
    final packageId = offer.terms.packageId;
    if (!offer.isPromoCode && packageId != null && packageId.isNotEmpty) {
      context.pushNamed(
        Routes.packageDetail,
        arguments: PackageDetailArgs(packageId: packageId),
      );
      return;
    }
    context.pushNamed(Routes.offers);
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
