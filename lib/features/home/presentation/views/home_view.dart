import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../data/models/banner_model.dart';
import 'package:aqua_go/features/subscriptions/data/models/subscription_response_model/subscription_response_model.dart';
import '../../controllers/services_controller/services_cubit.dart';
import '../../controllers/banners_controller/banners_cubit.dart';
import '../../controllers/packages_controller/packages_cubit.dart';
import 'package:aqua_go/features/subscriptions/controllers/subscriptions_controller/subscriptions_cubit.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/route/app_router.dart';
import 'package:aqua_go/features/booking/domain/configs/booking_flow_config.dart';
import 'package:aqua_go/features/booking/domain/strategies/package_booking_submit.dart';

import '../widgets/home_banners_carosal.dart';
import '../widgets/packages_list_view.dart';
import '../widgets/services_page_view.dart';
import '../widgets/offers_list_view.dart';
import '../widgets/current_package_section.dart';
import '../../../../core/helpers/shimmer_helper.dart';

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
  final PackagesCubit _packagesCubit = locator<PackagesCubit>();
  final SubscriptionsCubit _subscriptionsCubit = locator<SubscriptionsCubit>();

  @override
  void initState() {
    super.initState();
    _servicesCubit.getServices();
    _bannersCubit.getBanners();
    _packagesCubit.getPackages();
    _subscriptionsCubit.getActiveSubscriptions();
  }

  @override
  void dispose() {
    _servicesCubit.close();
    _bannersCubit.close();
    _packagesCubit.close();
    _subscriptionsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _servicesCubit),
        BlocProvider.value(value: _bannersCubit),
        BlocProvider.value(value: _packagesCubit),
        BlocProvider.value(value: _subscriptionsCubit),
      ],
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _servicesCubit.getServices(),
            _bannersCubit.getBanners(),
            _packagesCubit.getPackages(),
            _subscriptionsCubit.getActiveSubscriptions(),
          ]);
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              BlocBuilder<BannersCubit, BannersState>(
                builder: (context, state) {
                  final isLoading =
                      state is BannersLoading || state is BannersInitial;
                  List<BannerModel> activeBanners = [];
                  if (state is BannersLoaded) {
                    activeBanners = state.banners;
                  }
                  if (activeBanners.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return ShimmerHelper(
                    enabled: isLoading,
                    child: HomeBannersCarosal(
                      carouselController: _carouselController,
                      banners: activeBanners,
                    ),
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
                    BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
                      builder: (context, state) {
                        if (state is SubscriptionsError) {
                          return Column(
                            children: [
                              SizedBox(height: context.screenHeight * 0.02),
                              const PackagesListView(),
                            ],
                          );
                        }

                        final List<SubscriptionResponseModel> subscriptions;
                        if (state is SubscriptionsLoaded) {
                          subscriptions = state.subscriptions;
                        } else {
                          subscriptions = [];
                        }

                        if (subscriptions.isEmpty) {
                          return Column(
                            children: [
                              SizedBox(height: context.screenHeight * 0.02),
                              const PackagesListView(),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            SizedBox(height: context.screenHeight * 0.02),
                            CurrentPackageSection(
                              subscribedPackages: subscriptions,
                              onUsePackage: (package) {
                                context.pushNamed(
                                  Routes.bookingLocation,
                                  arguments: BookingFlowStartArgs(
                                    flowConfig: const BookingFlowConfig(
                                      flowType: BookingFlowType.package,
                                    ),
                                    submitStrategy: const PackageBookingSubmit(),
                                    subscriptionId: package.id,
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
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
