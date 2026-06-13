import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg.dart';
import 'package:aqua_go/core/components/error_retry_widget.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:aqua_go/features/subscriptions/data/models/subscription_response_model/subscription_response_model.dart';
import 'package:aqua_go/features/subscriptions/presentation/controllers/subscriptions_controller/subscriptions_cubit.dart';
import 'package:aqua_go/features/subscriptions/data/models/subscription_response_model/subscription_included_allowance.dart';
import 'package:aqua_go/features/booking/domain/configs/booking_flow_config.dart';
import 'package:aqua_go/features/booking/domain/strategies/package_booking_submit.dart';
import 'package:aqua_go/core/route/app_router.dart';

class MySubscribedPackagesView extends StatefulWidget {
  const MySubscribedPackagesView({super.key});

  @override
  State<MySubscribedPackagesView> createState() =>
      _MySubscribedPackagesViewState();
}

class _MySubscribedPackagesViewState extends State<MySubscribedPackagesView> {
  late final PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.profile_my_packages.tr(),
        centerTitle: false,
      ),
      body: BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
        builder: (context, subState) {
          if (subState is SubscriptionsLoading ||
              subState is SubscriptionsInitial) {
            return Center(child: CustomLoadingIndicator(size: 100));
          }

          if (subState is SubscriptionsError) {
            return ErrorRetryWidget(
              errorMessage: subState.message,
              onRetry: () {
                context.read<SubscriptionsCubit>().getActiveSubscriptions();
              },
            );
          }

          final List<SubscriptionResponseModel> subscriptions;
          if (subState is SubscriptionsLoaded) {
            subscriptions = subState.subscriptions;
          } else {
            subscriptions = [];
          }

          if (subscriptions.isEmpty) {
            return _buildEmptyState(context, sw, sh);
          }

          return Column(
            children: [
              SizedBox(height: sh(16)),
              if (subscriptions.length > 1) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    subscriptions.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPageIndex == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPageIndex == index
                            ? context.colors.primary
                            : context.colors.textSecondary.withValues(
                                alpha: 0.3,
                              ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: sh(12)),
              ],
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.colors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(sw(24)),
                      topRight: Radius.circular(sw(24)),
                    ),
                  ),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: subscriptions.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final sub = subscriptions[index];

                      final desc = context.isAr
                          ? 'هذه الباقة تمنحك ${sub.packageInfo.numWashes} غسلة صالحة لمدة ${sub.packageInfo.validityDays} يوم.'
                          : 'This package gives you ${sub.packageInfo.numWashes} washes valid for ${sub.packageInfo.validityDays} days.';

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: sw(24),
                          vertical: sh(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(
                              LocaleKeys.bookings_package_name.tr(),
                              context,
                            ),
                            SizedBox(height: sh(8)),
                            _buildPackageNameCard(sub, context, sw, sh),
                            SizedBox(height: sh(20)),

                            _buildSectionTitle(
                              LocaleKeys.booking_package_package_details.tr(),
                              context,
                            ),
                            SizedBox(height: sh(8)),
                            _buildDetailCard(desc, context, sw, sh),
                            SizedBox(height: sh(20)),

                            _buildSectionTitle(
                              LocaleKeys.bookings_total.tr(),
                              context,
                            ),
                            SizedBox(height: sh(8)),
                            _buildTotalCard(sub, context, sw, sh),
                            SizedBox(height: sh(20)),

                            _buildSectionTitle(
                              LocaleKeys.expiry_date.tr(),
                              context,
                            ),
                            SizedBox(height: sh(8)),
                            _buildExpiryCard(sub, context, sw, sh),

                            if (sub.includedAllowances.isNotEmpty) ...[
                              SizedBox(height: sh(20)),
                              _buildSectionTitle(
                                LocaleKeys.bookings_additional_services.tr(),
                                context,
                              ),
                              SizedBox(height: sh(8)),
                              _buildAdditionalServicesList(
                                sub.includedAllowances,
                                context,
                                sw,
                                sh,
                              ),
                            ],

                            SizedBox(
                              height: sh(100),
                            ), // Space so content is not hidden by the sticky button
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
        builder: (context, state) {
          if (state is SubscriptionsLoaded && state.subscriptions.isNotEmpty) {
            final currentSub = state.subscriptions[_currentPageIndex];
            return _buildBottomButton(context, currentSub);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.medium14.copyWith(
        color: context.colors.textSecondary,
      ),
    );
  }

  Widget _buildPackageNameCard(
    SubscriptionResponseModel package,
    BuildContext context,
    double Function(double) sw,
    double Function(double) sh,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw(16)),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(sw(12)),
        border: Border.all(
          color: context.colors.borderSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.title,
                  style: AppTextStyles.bold16.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.isAr
                      ? '${package.packageInfo.numWashes} غسلة'
                      : '${package.packageInfo.numWashes} washes',
                  style: AppTextStyles.regular12.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                LocaleKeys.home_remaining.tr(),
                style: AppTextStyles.regular10.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${package.remainingWashes}/${package.washesTotal}',
                style: AppTextStyles.bold18.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    String desc,
    BuildContext context,
    double Function(double) sw,
    double Function(double) sh,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw(16)),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(sw(12)),
        border: Border.all(
          color: context.colors.borderSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        desc,
        style: AppTextStyles.regular14.copyWith(
          color: context.colors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildTotalCard(
    SubscriptionResponseModel package,
    BuildContext context,
    double Function(double) sw,
    double Function(double) sh,
  ) {
    final double price = package.packagePriceMinor / 100;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw(16)),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(sw(12)),
        border: Border.all(
          color: context.colors.borderSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            LocaleKeys.bookings_total.tr(),
            style: AppTextStyles.regular14.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          Row(
            children: [
              Text(
                price.toStringAsFixed(2),
                style: AppTextStyles.bold18.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              SvgPicture.asset(
                AppAssets.currency,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  context.colors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryCard(
    SubscriptionResponseModel package,
    BuildContext context,
    double Function(double) sw,
    double Function(double) sh,
  ) {
    final formattedDate = DateFormat(
      'yyyy - MM - dd',
    ).format(package.expiryDate);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: sh(16), horizontal: sw(16)),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(sw(12)),
        border: Border.all(
          color: context.colors.borderSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Text(
          formattedDate,
          style: AppTextStyles.medium16.copyWith(
            color: context.colors.textPrimary,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalServicesList(
    List<SubscriptionIncludedAllowance> allowances,
    BuildContext context,
    double Function(double) sw,
    double Function(double) sh,
  ) {
    return Column(
      children: allowances.map((allowance) {
        final String name = context.isAr
            ? (allowance.nameAr ?? allowance.nameEn ?? allowance.addonId)
            : (allowance.nameEn ?? allowance.nameAr ?? allowance.addonId);

        return Container(
          margin: EdgeInsets.only(bottom: sh(10)),
          padding: EdgeInsets.all(sw(16)),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(sw(12)),
            border: Border.all(
              color: context.colors.borderSecondary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.medium14.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${allowance.remainingQty}/${allowance.totalQty}',
                style: AppTextStyles.bold16.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomButton(
    BuildContext context,
    SubscriptionResponseModel package,
  ) {
    return Container(
      color: context.colors.background,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: ElevatedButton(
        onPressed: () {
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
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          LocaleKeys.home_use_package.tr(),
          style: AppTextStyles.bold16.copyWith(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    double Function(double) sw,
    double Function(double) sh,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(sw(20)),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.card_membership,
              size: sw(64),
              color: context.colors.primary,
            ),
          ),
          SizedBox(height: sh(24)),
          Text(
            context.isAr ? 'لا توجد اشتراكات نشطة' : 'No Active Subscriptions',
            style: AppTextStyles.bold18.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: sh(8)),
          Text(
            context.isAr
                ? 'اشترك في إحدى باقاتنا لتستمتع بغسيل سيارتك بأسعار تفضيلية.'
                : 'Subscribe to one of our packages to enjoy washing your car at preferential rates.',
            textAlign: TextAlign.center,
            style: AppTextStyles.regular14.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: sh(32)),
          ElevatedButton(
            onPressed: () {
              context.pushReplacementNamed(Routes.packages);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.black,
              minimumSize: const Size(200, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              LocaleKeys.home_available_packages.tr(),
              style: AppTextStyles.bold16.copyWith(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
