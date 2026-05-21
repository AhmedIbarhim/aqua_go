import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../data/models/banner_model.dart';
import '../../data/models/current_package_model.dart';
import '../../controllers/services_controller/services_cubit.dart';
import '../../controllers/banners_controller/banners_cubit.dart';
import '../widgets/home_banners_carosal.dart';
import '../widgets/packages_list_view.dart';
import '../widgets/services_page_view.dart';
import '../widgets/offers_list_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  final ServicesCubit _servicesCubit = locator<ServicesCubit>();
  final BannersCubit _bannersCubit = locator<BannersCubit>();

  CurrentPackageModel dummyPackage = CurrentPackageModel(
    title: 'باقة اكوا كلاسيك',
    description:
        '5 غسلات . 5 مجاناً.....................................................................................',
    image: 'assets/images/gift_demo.png',
    remainingWashes: 8,
    totalWashes: 10,
    expiryDate: DateTime(2026, 9, 18),
  );

  @override
  void initState() {
    super.initState();
    _servicesCubit.getServices();
    _bannersCubit.getBanners();
  }

  @override
  void dispose() {
    _servicesCubit.close();
    _bannersCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _servicesCubit),
        BlocProvider.value(value: _bannersCubit),
      ],
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _servicesCubit.getServices(),
            _bannersCubit.getBanners(),
          ]);
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              BlocBuilder<BannersCubit, BannersState>(
                builder: (context, state) {
                  List<BannerModel> activeBanners = [];
                  if (state is BannersLoaded) {
                    activeBanners = state.banners;
                  } else {
                    // Loading / Initial / Error: Show placeholder static banner
                    activeBanners = [
                      BannerModel(
                        id: 'demo1',
                        locale: 'ar',
                        imageUrl: 'assets/images/banner_demo.png',
                        ctaType: 'NONE',
                        sortOrder: 1,
                      ),
                      BannerModel(
                        id: 'demo2',
                        locale: 'ar',
                        imageUrl: 'assets/images/banner_demo.png',
                        ctaType: 'NONE',
                        sortOrder: 2,
                      ),
                    ];
                  }
                  return HomeBannersCarosal(
                    carouselController: _carouselController,
                    banners: activeBanners,
                  );
                },
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
                    // SizedBox(height: context.screenHeight * 0.02),
                    // CurrentPackageSection(
                    //   currentPackage: dummyPackage,
                    //   onUsePackage: () {
                    //     // Handle use package
                    //   },
                    // ),
                    SizedBox(height: context.screenHeight * 0.02),
                    const PackagesListView(),
                    SizedBox(height: context.screenHeight * 0.02),
                    const ServicesPageView(),
                    SizedBox(height: context.screenHeight * 0.02),
                    const OffersListView(),
                    SizedBox(height: context.screenHeight * 0.15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
