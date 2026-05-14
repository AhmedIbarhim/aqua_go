import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../data/models/banner_model.dart';

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
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.banners[index].image,
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: double.infinity,
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
}
