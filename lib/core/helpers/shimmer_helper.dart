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
  }) =>
      HomeItemCardShimmer(width: width, height: height);

  // 1. Shimmer list/carousel for banners loading
  static Widget banners({CarouselSliderController? controller}) =>
      BannersShimmer(controller: controller);

  // 2. Shimmer list for packages in HomeView
  static Widget packages({double? height}) =>
      PackagesShimmer(height: height);

  // 3. Shimmer card for services in HomeView
  static Widget serviceCard({double? height}) =>
      ServiceCardShimmer(height: height);

  // 4. Shimmer list for offers in HomeView
  static Widget offers({double? height}) =>
      OffersShimmer(height: height);

  // 5. Shimmer list for my cars
  static Widget cars() => const CarsShimmer();

  // 6. Shimmer list for my addresses
  static Widget addresses() => const AddressesShimmer();

  // 7. Shimmer horizontal selection list for cars in booking flow
  static Widget bookingCars({
    int? selectedCarIndex,
    Function(int)? onCarSelected,
    VoidCallback? onAddCar,
  }) =>
      BookingCarsShimmer(
        selectedCarIndex: selectedCarIndex,
        onCarSelected: onCarSelected,
        onAddCar: onAddCar,
      );

  // 8. Shimmer vertical list for addresses in booking flow
  static Widget bookingAddresses({
    int? selectedAddressIndex,
    Function(int)? onAddressSelected,
  }) =>
      BookingAddressesShimmer(
        selectedAddressIndex: selectedAddressIndex,
        onAddressSelected: onAddressSelected,
      );

  // Unified list in all packages page
  static Widget packagesList({int itemCount = 3}) =>
      PackagesListShimmer(itemCount: itemCount);

  // 9. Shimmer stand-in for the booking summary's price breakdown, shown while
  //    the backend quote is still out.
  static Widget paymentSummary() => const PaymentSummaryShimmer();
}

// ==========================================
// Standard Standalone Shimmer Widgets
// ==========================================

class HomeItemCardShimmer extends StatelessWidget {
  final double? width;
  final double? height;

  const HomeItemCardShimmer({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkTheme;
    return ShimmerHelper(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxH = constraints.maxHeight;
            final isSmall = maxH != double.infinity && maxH < 130;

            final paddingVal = isSmall ? 10.0 : 16.0;
            final spacingVal = isSmall ? 8.0 : 16.0;
            final topRowHeight = isSmall ? 32.0 : 40.0;
            final titleHeight = isSmall ? 14.0 : 16.0;
            final subtitleHeight = isSmall ? 10.0 : 12.0;
            final priceHeight = isSmall ? 20.0 : 24.0;
            final badgeHeight = isSmall ? 14.0 : 18.0;

            return Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(paddingVal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: topRowHeight,
                            height: topRowHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          Container(
                            width: 60,
                            height: badgeHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacingVal),
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
                                  height: titleHeight,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                SizedBox(height: isSmall ? 4 : 6),
                                Container(
                                  width: double.infinity,
                                  height: subtitleHeight,
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
                            height: priceHeight,
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
              ),
            );
          },
        ),
      ),
    );
  }
}

class BannersShimmer extends StatelessWidget {
  final CarouselSliderController? controller;

  const BannersShimmer({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return ShimmerHelper(
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
              height: context.isTablet ? height * 0.22 : height * 0.18,
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
  }
}

class PackagesShimmer extends StatelessWidget {
  final double? height;

  const PackagesShimmer({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    final h = height ?? 140.0;
    return SizedBox(
      height: h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) =>
            HomeItemCardShimmer(width: 280, height: h),
      ),
    );
  }
}

class ServiceCardShimmer extends StatelessWidget {
  final double? height;

  const ServiceCardShimmer({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    final h = height ?? 120.0;
    return SizedBox(
      height: h,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: HomeItemCardShimmer(width: double.infinity, height: h),
      ),
    );
  }
}

class OffersShimmer extends StatelessWidget {
  final double? height;

  const OffersShimmer({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    final h = height ?? 180.0;
    return SizedBox(
      height: h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) =>
            HomeItemCardShimmer(width: h * 1.8, height: h),
      ),
    );
  }
}

class CarsShimmer extends StatelessWidget {
  const CarsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerHelper(
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
  }
}

class AddressesShimmer extends StatelessWidget {
  const AddressesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerHelper(
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
  }
}

class BookingCarsShimmer extends StatelessWidget {
  final int? selectedCarIndex;
  final Function(int)? onCarSelected;
  final VoidCallback? onAddCar;

  const BookingCarsShimmer({
    super.key,
    this.selectedCarIndex,
    this.onCarSelected,
    this.onAddCar,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: height * 0.14,
      child: ShimmerHelper(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          separatorBuilder: (context, index) => SizedBox(width: width * 0.02),
          itemBuilder: (context, index) {
            return Container(
              width: width * 0.28,
              padding: EdgeInsets.all(width * 0.03),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
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
              ),
            );
          },
        ),
      ),
    );
  }
}

class BookingAddressesShimmer extends StatelessWidget {
  final int? selectedAddressIndex;
  final Function(int)? onAddressSelected;

  const BookingAddressesShimmer({
    super.key,
    this.selectedAddressIndex,
    this.onAddressSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerHelper(
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
  }
}

/// Stand-in for `PaymentSummaryCard` while the quote it renders is still out.
///
/// It mirrors that card's shape — a couple of label/amount rows, the total
/// rule, and the VAT footnote — so the section keeps its height and the real
/// figures land in place instead of pushing the page around. It shows no
/// number at all, which is the point: a fabricated SAR 0.00 is a price the
/// customer can read and believe.
class PaymentSummaryShimmer extends StatelessWidget {
  const PaymentSummaryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerHelper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(labelWidth: 140, amountWidth: 70, height: 16),
          const SizedBox(height: 12),
          _row(labelWidth: 110, amountWidth: 70, height: 16),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Colors.white),
          const SizedBox(height: 12),
          _row(labelWidth: 90, amountWidth: 90, height: 18),
          const SizedBox(height: 8),
          _row(labelWidth: 160, amountWidth: 50, height: 12),
        ],
      ),
    );
  }

  // Direction-agnostic: a spaceBetween Row lays itself out RTL in Arabic with
  // no branching, exactly as PaymentSummaryCard._buildPaymentRow does.
  Widget _row({
    required double labelWidth,
    required double amountWidth,
    required double height,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _bar(width: labelWidth, height: height),
        _bar(width: amountWidth, height: height),
      ],
    );
  }

  Widget _bar({required double width, required double height}) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

class PackagesListShimmer extends StatelessWidget {
  final int itemCount;

  const PackagesListShimmer({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) =>
          const HomeItemCardShimmer(width: double.infinity),
    );
  }
}
