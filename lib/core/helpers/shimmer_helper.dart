import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../extentions/context_extentions.dart';

class ShimmerHelper extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const ShimmerHelper({super.key, required this.child, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    final isDark = context.isDarkTheme;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0),
      highlightColor: isDark
          ? const Color(0xFF3F3F3F)
          : const Color(0xFFF1F5F9),
      child: child,
    );
  }

  // Unified card for home items (packages, services, offers, etc.)
  static Widget homeItemCard(
    BuildContext context, {
    double? width,
    double? height,
  }) {
    final isDark = context.isDarkTheme;
    final baseColor = isDark
        ? const Color(0xFF262626)
        : const Color(0xFFE2E8F0);
    final highlightColor = isDark
        ? const Color(0xFF3F3F3F)
        : const Color(0xFFF1F5F9);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  width: 60,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 50,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 1. Shimmer list/carousel for banners loading
  static Widget banners({CarouselSliderController? controller}) {
    return Builder(
      builder: (context) {
        final isDark = context.isDarkTheme;
        final baseColor = isDark
            ? const Color(0xFF262626)
            : const Color(0xFFE2E8F0);
        final highlightColor = isDark
            ? const Color(0xFF3F3F3F)
            : const Color(0xFFF1F5F9);
        final height = MediaQuery.sizeOf(context).height;
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Column(
            children: [
              CarouselSlider.builder(
                carouselController: controller ?? CarouselSliderController(),
                itemCount: 3,
                itemBuilder: (context, index, realIndex) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: context.isTablet
                      ? height * 0.22
                      : height * 0.18,
                  viewportFraction: context.isTablet ? 0.6 : 0.75,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  autoPlay: false,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.2,
                  scrollDirection: Axis.horizontal,
                  enlargeStrategy: CenterPageEnlargeStrategy.scale,
                ),
              ),
              SizedBox(height: height * 0.012),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. Shimmer list for packages in HomeView
  static Widget packages({double? height}) {
    return Builder(
      builder: (context) {
        final h = height ?? 140.0;
        return SizedBox(
          height: h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) =>
                homeItemCard(context, width: 280, height: h),
          ),
        );
      },
    );
  }

  // 3. Shimmer card for services in HomeView
  static Widget serviceCard({double? height}) {
    return Builder(
      builder: (context) {
        final h = height ?? 120.0;
        return SizedBox(
          height: h,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: homeItemCard(context, width: double.infinity, height: h),
          ),
        );
      },
    );
  }

  // 4. Shimmer list for offers in HomeView
  static Widget offers({double? height}) {
    return Builder(
      builder: (context) {
        final h = height ?? 180.0;
        return SizedBox(
          height: h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) =>
                homeItemCard(context, width: h * 1.8, height: h),
          ),
        );
      },
    );
  }

  // 5. Shimmer list for my cars
  static Widget cars() {
    return Builder(
      builder: (context) {
        final isDark = context.isDarkTheme;
        final baseColor = isDark
            ? const Color(0xFF262626)
            : const Color(0xFFE2E8F0);
        final highlightColor = isDark
            ? const Color(0xFF3F3F3F)
            : const Color(0xFFF1F5F9);

        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  // 6. Shimmer list for my addresses
  static Widget addresses() {
    return Builder(
      builder: (context) {
        final isDark = context.isDarkTheme;
        final baseColor = isDark
            ? const Color(0xFF262626)
            : const Color(0xFFE2E8F0);
        final highlightColor = isDark
            ? const Color(0xFF3F3F3F)
            : const Color(0xFFF1F5F9);

        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 7. Shimmer horizontal selection list for cars in booking flow
  static Widget bookingCars({
    int? selectedCarIndex,
    Function(int)? onCarSelected,
    VoidCallback? onAddCar,
  }) {
    return Builder(
      builder: (context) {
        final width = MediaQuery.sizeOf(context).width;
        final height = MediaQuery.sizeOf(context).height;
        final isDark = context.isDarkTheme;
        final baseColor = isDark
            ? const Color(0xFF262626)
            : const Color(0xFFE2E8F0);
        final highlightColor = isDark
            ? const Color(0xFF3F3F3F)
            : const Color(0xFFF1F5F9);

        return SizedBox(
          height: height * 0.14,
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (context, index) =>
                  SizedBox(width: width * 0.02),
              itemBuilder: (context, index) {
                return Container(
                  width: width * 0.28,
                  padding: EdgeInsets.all(width * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: height * 0.055,
                        height: height * 0.055,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // 8. Shimmer vertical list for addresses in booking flow
  static Widget bookingAddresses({
    int? selectedAddressIndex,
    Function(int)? onAddressSelected,
  }) {
    return Builder(
      builder: (context) {
        final isDark = context.isDarkTheme;
        final baseColor = isDark
            ? const Color(0xFF262626)
            : const Color(0xFFE2E8F0);
        final highlightColor = isDark
            ? const Color(0xFF3F3F3F)
            : const Color(0xFFF1F5F9);

        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 3,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Unified list in all packages page
  static Widget packagesList({int itemCount = 3}) {
    return Builder(
      builder: (context) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: itemCount,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) =>
              homeItemCard(context, width: double.infinity),
        );
      },
    );
  }
}
