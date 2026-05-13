import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../data/models/offer_model.dart';
import 'offer_card.dart';
import '../views/offers_view.dart';

class OffersListView extends StatefulWidget {
  const OffersListView({super.key});

  @override
  State<OffersListView> createState() => _OffersListViewState();
}

class _OffersListViewState extends State<OffersListView> {
  final List<OfferModel> offers = [
    OfferModel(image: "assets/images/offer_demo.png"),
    OfferModel(image: "assets/images/offer_demo.png"),
    OfferModel(image: "assets/images/offer_demo.png"),
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.home_best_offers.tr(),
                style: !context.isTablet
                    ? AppTextStyles.bold16
                    : AppTextStyles.bold18,
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed(
                    Routes.offers,
                    arguments: OffersArgs(offers: offers),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      LocaleKeys.home_view_more.tr(),
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
        ),

        SizedBox(height: height * 0.012),
        SizedBox(
          height: height * 0.21,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: offers.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) =>
                OfferCard(offerModel: offers[index]),
          ),
        ),
      ],
    );
  }
}
