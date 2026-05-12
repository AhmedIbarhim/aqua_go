import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../data/models/banner_model.dart';

class HomeBannersCarosal extends StatefulWidget {
  const HomeBannersCarosal({
    super.key,
    required this.banners,
    // required this.width,
    required this.carouselController,
  });
  final List<BannerModel> banners;
  // final double width;
  final CarouselSliderController carouselController;

  @override
  State<HomeBannersCarosal> createState() => _HomeBannersCarosalState();
}

class _HomeBannersCarosalState extends State<HomeBannersCarosal> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.sizeOf(context).height;
    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: widget.carouselController,
          itemCount: widget.banners.length,
          itemBuilder: (context, index, realIndex) {
            return Container(
              // width: widget.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                widget.banners[index].image,
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
              ),
            );
          },
          options: CarouselOptions(
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
            aspectRatio: 100 / 37,
            viewportFraction: 0.75,
            initialPage: 0,
            enableInfiniteScroll: true,
            //reverse: true,
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
          SizedBox(height: height * 0.01),
          DotsIndicator(
            dotsCount: widget.banners.length,
            position: _currentIndex.toDouble(),
            decorator: DotsDecorator(
              activeColor: context.colors.contentSecondaryLight,
              color: context.colors.contentSecondary,
              size: const Size(6, 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              spacing: const EdgeInsets.all(4),
              activeSize: const Size(6, 6),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
