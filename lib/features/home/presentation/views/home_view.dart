import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors_extension.dart';
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
    var height = MediaQuery.of(context).size.height;
    return RefreshIndicator(
      onRefresh: () async {
        // Reload data here
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.2,
              child: HomeBannersCarosal(
                carouselController: _carouselController,
                banners: banners,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const PackagesListView(),
                  const SizedBox(height: 24),
                  const ServicesListView(),
                  const SizedBox(height: 24),
                  const OffersListView(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
