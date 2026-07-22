import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/session/session_state.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/helpers/fetch_user_data_helper.dart';
import '../../../../core/route/app_router.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../subscriptions/presentation/widgets/package_subscribtion_bottom_sheet.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/package_model.dart';
import '../../data/models/service_model.dart';
import 'offer_card.dart';
import '../views/offers_view.dart';
import '../../../../core/helpers/shimmer_helper.dart';

class OffersListView extends StatefulWidget {
  final bool isLoading;
  final List<PackageModel> packages;
  final List<ServiceModel> services;
  const OffersListView({
    super.key,
    this.isLoading = false,
    this.packages = const [],
    this.services = const [],
  });

  @override
  State<OffersListView> createState() => _OffersListViewState();
}

class _OffersListViewState extends State<OffersListView> {
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
              // GestureDetector(
              //   onTap: () {
              //     context.pushNamed(
              //       Routes.offers,
              //       arguments: OffersArgs(offers: getDemoOffers(context)),
              //     );
              //   },
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.end,
              //     children: [
              //       Text(
              //         LocaleKeys.home_view_more.tr(context: context),
              //         style: AppTextStyles.regular12.copyWith(
              //           color: context.colors.primary,
              //         ),
              //       ),
              //       const SizedBox(width: 6),
              //       Container(
              //         padding: const EdgeInsets.symmetric(
              //           horizontal: 2,
              //           vertical: 2,
              //         ),
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(4),
              //           border: Border.all(
              //             color: context.colors.primary,
              //             width: 1,
              //           ),
              //         ),
              //         child: Icon(
              //           Icons.arrow_forward_ios,
              //           size: 10,
              //           color: context.colors.primary,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),

        SizedBox(height: height * 0.012),
        SizedBox(
          height: height * 0.21,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: getDemoOffers(context).length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () =>
                  _handleOfferTap(context, getDemoOffers(context)[index]),
              child: OfferCard(offerModel: getDemoOffers(context)[index]),
            ),
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
        ctaType: 'DEEPLINK',
        ctaTarget: 'services',
        serviceId: "00000000-0000-0000-0000-000000000d12",
        sortOrder: 1,
      ),
      OfferModel(
        id: '2',
        locale: context.isAr ? 'ar' : 'en',
        imageUrl: demoOffers()[1],
        ctaType: 'DEEPLINK',
        ctaTarget: 'packages',
        packageId: "00000000-0000-0000-0000-000000a80003",
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

  Future<void> _handleOfferTap(BuildContext context, OfferModel offer) async {
    switch (offer.ctaType) {
      case 'URL':
        final target = offer.ctaTarget;
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
        switch (offer.ctaTarget) {
          case 'packages':
            if (offer.packageId != null && widget.packages.isNotEmpty) {
              final package = widget.packages.firstWhere(
                (p) => p.id == offer.packageId,
                orElse: () => widget.packages.first,
              );
              if (currentUser.value == null) {
                FetchUserData.promptGuestToLogin(context);
              } else {
                PackageSubscribtionBottomSheet.show(
                  context,
                  packageModel: package,
                );
              }
            } else {
              context.pushNamed(Routes.packages);
            }
            break;
          case 'services':
            if (offer.serviceId != null && widget.services.isNotEmpty) {
              final service = widget.services.firstWhere(
                (s) => s.id == offer.serviceId,
                orElse: () => widget.services.first,
              );
              if (currentUser.value == null) {
                FetchUserData.promptGuestToLogin(context);
              } else {
                context.pushNamed(
                  Routes.bookingLocation,
                  arguments: BookingFlowStartArgs(service: service),
                );
              }
            } else {}
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
