import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../data/models/banner_model.dart';
import '../widgets/home_banners_carosal.dart';
import '../widgets/packages_list_view.dart';
import '../widgets/services_list_view.dart';
import '../widgets/offers_list_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  List<BannerModel> banners = [
    BannerModel(image: "assets/images/banner_demo.png"),
    BannerModel(image: "assets/images/banner_demo.png"),
    BannerModel(image: "assets/images/banner_demo.png"),
  ];
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Reload data here
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            HomeBannersCarosal(
              carouselController: _carouselController,
              banners: banners,
            ),
            SizedBox(height: context.screenHeight * 0.01),
            Container(
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: context.screenHeight * 0.02),
                  const PackagesListView(),
                  SizedBox(height: context.screenHeight * 0.02),
                  const ServicesListView(),
                  SizedBox(height: context.screenHeight * 0.02),
                  const OffersListView(),
                  SizedBox(height: context.screenHeight * 0.15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
