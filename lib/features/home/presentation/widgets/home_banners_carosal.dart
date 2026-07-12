import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/components/custom_dots_indicator.dart';
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
          itemCount: widget.banners.length,
          itemBuilder: (context, index, realIndex) {
            final banner = widget.banners[index];
            final bannerImage = banner.image;
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
          CustomDotsIndicator(
            count: widget.banners.length,
            currentIndex: _currentIndex,
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
}
