import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/offer_model.dart';
import 'offer_card.dart';
import '../views/offers_view.dart';
import '../../../../core/helpers/shimmer_helper.dart';

class OffersCarouselView extends StatefulWidget {
  final bool isLoading;
  const OffersCarouselView({super.key, this.isLoading = false});

  @override
  State<OffersCarouselView> createState() => _OffersCarouselViewState();
}

class _OffersCarouselViewState extends State<OffersCarouselView> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    if (widget.isLoading) {
      return Column(
        children: [
          Padding(
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
              ],
            ),
          ),
          SizedBox(height: height * 0.012),
          ShimmerHelper.offers(height: height * 0.21),
        ],
      );
    }
    final offers = getDemoOffers(context);
    return Column(
      children: [
        Padding(
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
        ),

        SizedBox(height: height * 0.012),
        SizedBox(
          height: height * 0.21,
          child: CarouselView(
            itemExtent: height * 0.4,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            onTap: (index) => _handleOfferTap(context, offers[index]),
            children: offers.map((offer) {
              return OfferCard(offerModel: offer);
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<String> demoOffers() {
    if (context.isAr) {
      return [
        AppAssets.offersOneAr,
        AppAssets.offersTwoAr,
        AppAssets.offersThreeAr,
      ];
    } else {
      return [
        AppAssets.offersOneEn,
        AppAssets.offersTwoEn,
        AppAssets.offersThreeEn,
      ];
    }
  }

  List<OfferModel> getDemoOffers(BuildContext context) {
    final List<OfferModel> offers = [
      OfferModel(
        id: '1',
        locale: context.isAr ? 'ar' : 'en',
        imageUrl: demoOffers()[0],
        ctaType: 'URL',
        ctaTarget: 'https://aquago.sa/',
        sortOrder: 1,
      ),
      OfferModel(
        id: '2',
        locale: context.isAr ? 'ar' : 'en',
        imageUrl: demoOffers()[1],
        ctaType: 'DEEPLINK',
        ctaTarget: 'packages',
        sortOrder: 2,
      ),
      OfferModel(
        id: '3',
        locale: context.isAr ? 'ar' : 'en',
        imageUrl: demoOffers()[2],
        ctaType: 'DEEPLINK',
        ctaTarget: 'packages',
        sortOrder: 3,
      ),
    ];
    return offers;
  }

  Future<void> _handleOfferTap(BuildContext context, OfferModel banner) async {
    switch (banner.ctaType) {
      case 'URL':
        final target = banner.ctaTarget;
        if (target == null || target.isEmpty) return;
        try {
          final ok = await launchUrl(
            Uri.parse(target),
            mode: LaunchMode.externalApplication,
          );
          if (!ok && context.mounted) {
            context.showWarningSnackBar(
              context.isAr ? 'تعذّر فتح الرابط.' : 'Could not open the link.',
            );
          }
        } catch (_) {
          if (context.mounted) {
            context.showWarningSnackBar(
              context.isAr ? 'تعذّر فتح الرابط.' : 'Could not open the link.',
            );
          }
        }
        break;
      case 'DEEPLINK':
        switch (banner.ctaTarget) {
          case 'packages':
            Navigator.pushNamed(context, Routes.packages);
            break;
          default:
            // Unknown deeplink target — safe no-op.
            break;
        }
        break;
      default:
        // 'NONE' / null / unknown — no-op.
        break;
    }
  }
}
