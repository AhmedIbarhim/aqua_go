import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../../core/config/session/session_state.dart';
import '../../data/models/banner_model.dart';
import '../../data/models/package_model.dart';
import '../../data/models/service_model.dart';
import 'package:aqua_go/features/auth/data/models/user_model.dart';
import 'package:aqua_go/features/subscriptions/data/models/subscription_response_model/subscription_response_model.dart';
import '../controllers/services_controller/services_cubit.dart';
import '../controllers/banners_controller/banners_cubit.dart';
import '../controllers/packages_controller/packages_cubit.dart';
import 'package:aqua_go/features/subscriptions/presentation/controllers/subscriptions_controller/subscriptions_cubit.dart';
import 'package:aqua_go/features/rating/presentation/controllers/pending_ratings_cubit/pending_ratings_cubit.dart';
import 'package:aqua_go/features/rating/presentation/controllers/pending_ratings_cubit/pending_ratings_state.dart';
import 'package:aqua_go/features/rating/presentation/widgets/rating_bottom_sheet.dart';
import 'package:aqua_go/features/rating/data/dismissed_ratings_store.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/route/app_router.dart';
import 'package:aqua_go/features/booking/domain/configs/booking_flow_config.dart';
import 'package:aqua_go/features/booking/domain/strategies/package_booking_submit.dart';
import '../widgets/home_banners_carosal.dart';
import '../widgets/offers_list_view.dart';
import '../widgets/packages_list_view.dart';
import '../widgets/services_page_view.dart';
import '../widgets/current_package_section.dart';
import '../../../../core/helpers/shimmer_helper.dart';
import '../../../../core/components/error_retry_widget.dart';

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
  final PendingRatingsCubit _pendingRatingsCubit =
      locator<PendingRatingsCubit>();

  // AQG-160: prompt the home rating popup at most once per HomeView lifecycle,
  // so widget rebuilds / re-emits never re-open an already-handled sheet.
  bool _ratingPromptShown = false;

  @override
  void initState() {
    super.initState();
    _servicesCubit.getServices();
    _bannersCubit.getBanners();
    _packagesCubit.getPackages();
    if (currentUser.value != null) {
      _subscriptionsCubit.getActiveSubscriptions();
      // Fire-and-forget: never block home rendering on the rating nudge.
      _pendingRatingsCubit.fetchPendingRatings();
    }
    // Load subscriptions reactively when user transitions from guest to logged-in.
    currentUser.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (currentUser.value != null) {
      _subscriptionsCubit.getActiveSubscriptions();
      _pendingRatingsCubit.fetchPendingRatings();
    }
  }

  Future<void> _showRatingPopup(BookingResponseModel booking) async {
    final bookingId = booking.id;
    if (bookingId == null || bookingId.isEmpty) return;
    _ratingPromptShown = true;

    await RatingBottomSheet.show(context, booking, navigateOnSuccess: false);

    // The sheet is now closed — whether the user rated or dismissed. Remember
    // this booking id locally so it is never re-prompted on a later home load.
    // (Rated bookings also drop off the endpoint naturally, so this is a safe
    // no-cost record on the rate path and the deliberate user decision on the
    // dismiss path.)
    await DismissedRatingsStore.dismiss(bookingId);
  }

  @override
  void dispose() {
    currentUser.removeListener(_onAuthChanged);
    _servicesCubit.close();
    _bannersCubit.close();
    _packagesCubit.close();
    _pendingRatingsCubit.close();
    // _subscriptionsCubit is a shared lazy singleton (see service_locator):
    // do NOT close it here, otherwise other surfaces lose their data source
    // and a post-subscribe refetch can't propagate.
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
        BlocProvider.value(value: _pendingRatingsCubit),
      ],
      child: BlocListener<PendingRatingsCubit, PendingRatingsState>(
        listener: (context, state) {
          if (state is PendingRatingsLoaded &&
              state.bookings.isNotEmpty &&
              !_ratingPromptShown &&
              currentUser.value != null &&
              mounted) {
            // Prompt with the most-recently-completed unrated booking.
            _showRatingPopup(state.bookings.first);
          }
        },
        child: ValueListenableBuilder<UserModel?>(
          valueListenable: currentUser,
          builder: (context, user, _) {
            final isLoggedIn = user != null;
            return BlocBuilder<ServicesCubit, ServicesState>(
              builder: (context, servicesState) {
                return BlocBuilder<PackagesCubit, PackagesState>(
                  builder: (context, packagesState) {
                    final isServicesError = servicesState is ServicesError;
                    final isPackagesError = packagesState is PackagesError;

                    if (isServicesError || isPackagesError) {
                      final String errorMessage = isServicesError
                          ? servicesState.message
                          : (packagesState as PackagesError).message;

                      return Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: context.colors.background,
                        child: Center(
                          child: ErrorRetryWidget(
                            errorMessage: errorMessage,
                            onRetry: () async {
                              await Future.wait([
                                _servicesCubit.getServices(),
                                _bannersCubit.getBanners(),
                                _packagesCubit.getPackages(),
                                if (isLoggedIn)
                                  _subscriptionsCubit.getActiveSubscriptions(),
                              ]);
                            },
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await Future.wait([
                          _servicesCubit.getServices(),
                          _bannersCubit.getBanners(),
                          _packagesCubit.getPackages(),
                          if (isLoggedIn)
                            _subscriptionsCubit.getActiveSubscriptions(),
                        ]);
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            BlocBuilder<BannersCubit, BannersState>(
                              builder: (context, state) {
                                final isLoading =
                                    state is BannersLoading ||
                                    state is BannersInitial;
                                if (isLoading) {
                                  return ShimmerHelper.banners(
                                    controller: _carouselController,
                                  );
                                }
                                List<BannerModel> activeBanners = [];
                                if (state is BannersLoaded) {
                                  activeBanners = state.banners;
                                }
                                if (activeBanners.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                final services = servicesState is ServicesLoaded
                                    ? servicesState.services
                                    : const <ServiceModel>[];
                                final packages = packagesState is PackagesLoaded
                                    ? packagesState.packages
                                    : const <PackageModel>[];
                                return HomeBannersCarosal(
                                  carouselController: _carouselController,
                                  banners: activeBanners,
                                  packages: packages,
                                  services: services,
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
                                  BlocBuilder<
                                    SubscriptionsCubit,
                                    SubscriptionsState
                                  >(
                                    builder: (context, state) {
                                      if (state is SubscriptionsError) {
                                        return Column(
                                          children: [
                                            SizedBox(
                                              height:
                                                  context.screenHeight * 0.02,
                                            ),
                                            const PackagesListView(),
                                          ],
                                        );
                                      }

                                      final List<SubscriptionResponseModel>
                                      subscriptions;
                                      if (state is SubscriptionsLoaded) {
                                        subscriptions = state.subscriptions;
                                      } else {
                                        subscriptions = [];
                                      }

                                      if (subscriptions.isEmpty) {
                                        return Column(
                                          children: [
                                            SizedBox(
                                              height:
                                                  context.screenHeight * 0.02,
                                            ),
                                            const PackagesListView(),
                                          ],
                                        );
                                      }

                                      return Column(
                                        children: [
                                          SizedBox(
                                            height: context.screenHeight * 0.02,
                                          ),
                                          CurrentPackageSection(
                                            subscribedPackages: subscriptions,
                                            onUsePackage: (package) {
                                              context.pushNamed(
                                                Routes.bookingLocation,
                                                arguments: BookingFlowStartArgs(
                                                  flowConfig:
                                                      const BookingFlowConfig(
                                                        flowType:
                                                            BookingFlowType
                                                                .package,
                                                      ),
                                                  submitStrategy:
                                                      const PackageBookingSubmit(),
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
                                  SizedBox(height: context.screenHeight * 0.03),
                                  Builder(
                                    builder: (context) {
                                      final services =
                                          servicesState is ServicesLoaded
                                          ? servicesState.services
                                          : const <ServiceModel>[];
                                      final packages =
                                          packagesState is PackagesLoaded
                                          ? packagesState.packages
                                          : const <PackageModel>[];
                                      return OffersListView(
                                        packages: packages,
                                        services: services,
                                      );
                                    },
                                  ),
                                  SizedBox(height: context.screenHeight * 0.15),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
