import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/utils/app_assets.dart';
import '../../data/models/banner_model.dart';

class HomeBannersCarosal extends StatefulWidget {
  const HomeBannersCarosal({
    super.key,
    required this.banners,
    required this.carouselController,
  });
  final List<BannerModel> banners;
  final CarouselSliderController carouselController;

  @override
  State<HomeBannersCarosal> createState() => _HomeBannersCarosalState();
}

class _HomeBannersCarosalState extends State<HomeBannersCarosal> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: widget.carouselController,
          itemCount: getDemoBanners().length,
          itemBuilder: (context, index, realIndex) {
            final banner = getDemoBanners()[index];
            final bannerImage = banner.imageUrl;
            final isNetworkImage =
                bannerImage.startsWith('http') ||
                bannerImage.startsWith('https');

            return GestureDetector(
              onTap: () => _handleBannerTap(context, banner),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isNetworkImage
                      ? CachedNetworkImage(
                          imageUrl: bannerImage,
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => Container(
                            color: context.colors.defaultSubtle,
                            // child: const Center(
                            //   child: CircularProgressIndicator(),
                            // ),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            AppAssets.demoBanner,
                            fit: BoxFit.fill,
                          ),
                        )
                      : Image.asset(
                          bannerImage,
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                ),
              ),
            );
          },
          options: CarouselOptions(
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
            height: context.isTablet
                ? context.screenHeight * 0.22
                : context.screenHeight * 0.18,
            viewportFraction: context.isTablet ? 0.6 : 0.75,
            initialPage: 0,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            scrollDirection: Axis.horizontal,
            enlargeStrategy: CenterPageEnlargeStrategy.scale,
          ),
        ),
        if (widget.banners.isNotEmpty) ...[
          SizedBox(height: context.screenHeight * 0.012),
          DotsIndicator(
            dotsCount: widget.banners.length,
            position: _currentIndex.toDouble(),
            decorator: DotsDecorator(
              activeColor: context.colors.contentSecondaryLight,
              color: context.colors.contentSecondary,
              size: Size(
                context.screenWidth * 0.015,
                context.screenWidth * 0.015,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  context.screenWidth * 0.015,
                ),
              ),
              spacing: EdgeInsets.all(context.screenWidth * 0.01),
              activeSize: Size(
                context.screenWidth * 0.015,
                context.screenWidth * 0.015,
              ),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  context.screenWidth * 0.015,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleBannerTap(
    BuildContext context,
    BannerModel banner,
  ) async {
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

  List<String> demoBanners() {
    if (context.isAr) {
      return [
        AppAssets.bannersOneAr,
        AppAssets.bannersTwoAr,
        AppAssets.bannersThreeAr,
      ];
    } else {
      return [
        AppAssets.bannersOneEn,
        AppAssets.bannersTwoEn,
        AppAssets.bannersThreeEn,
      ];
    }
  }

  List<BannerModel> getDemoBanners() {
    return [
      BannerModel(
        id: '0',
        imageUrl: demoBanners().first,
        ctaType: 'URL',
        ctaTarget: 'https://aquago.sa/',
        locale: context.isAr ? 'ar' : 'en',
        sortOrder: 0,
      ),
      BannerModel(
        id: '1',
        imageUrl: demoBanners()[1],
        ctaType: 'URL',
        ctaTarget: 'https://aquago.sa/',
        locale: context.isAr ? 'ar' : 'en',
        sortOrder: 1,
      ),
      BannerModel(
        id: '2',
        imageUrl: demoBanners()[2],
        ctaType: 'URL',
        ctaTarget: "https://aquago.sa/",
        locale: context.isAr ? 'ar' : 'en',
        sortOrder: 2,
      ),
    ];
  }
}
