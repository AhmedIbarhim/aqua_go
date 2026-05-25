import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/components/custom_loading_indicator.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/config/di/service_locator.dart';
import '../widgets/my_bookings_list_view.dart';
import '../widgets/my_bookings_tabs.dart';
import '../widgets/empty_bookings_widget.dart';
import '../../../../core/helpers/fetch_user_data_helper.dart';
import '../../../../core/components/guest_placeholder_widget.dart';
import '../../controllers/my_bookings_cubit.dart';
import '../../controllers/my_bookings_state.dart';

class MyBookingsView extends StatefulWidget {
  const MyBookingsView({super.key});

  @override
  State<MyBookingsView> createState() => _MyBookingsViewState();
}

class _MyBookingsViewState extends State<MyBookingsView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (FetchUserData.isGuest()) {
      return Scaffold(
        backgroundColor: context.colors.screenBG,
        body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: const GuestPlaceholderWidget(
            titleEn: "Your Bookings",
            titleAr: "حجوزاتك",
            descEn:
                "Please log in to track and view your active and past bookings.",
            descAr: "يرجى تسجيل الدخول لمتابعة وعرض حجوزاتك الحالية والسابقة.",
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => locator<MyBookingsCubit>()..fetchBookings(),
      child: Scaffold(
        backgroundColor: context.colors.screenBG,
        body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              MyBookingsTabs(
                selectedIndex: _selectedIndex,
                onTabChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<MyBookingsCubit, MyBookingsState>(
                  builder: (context, state) {
                    if (state is MyBookingsLoading) {
                      return const Center(
                        child: CustomLoadingIndicator(size: 80),
                      );
                    } else if (state is MyBookingsFailure) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.errMessage,
                              style: AppTextStyles.medium16.copyWith(
                                color: context.colors.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.colors.primary,
                              ),
                              onPressed: () {
                                context.read<MyBookingsCubit>().fetchBookings();
                              },
                              child: Text(
                                context.locale.languageCode == 'ar'
                                    ? 'إعادة المحاولة'
                                    : 'Retry',
                                style: AppTextStyles.medium14.copyWith(
                                  color: context.colors.themeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (state is MyBookingsSuccess) {
                      final filteredBookings = state.bookings
                          .where(
                            (booking) => _selectedIndex == 0
                                ? booking.isUpcoming
                                : !booking.isUpcoming,
                          )
                          .toList();

                      if (filteredBookings.isEmpty) {
                        return RefreshIndicator(
                          color: context.colors.primary,
                          onRefresh: () async {
                            await context.read<MyBookingsCubit>().fetchBookings(
                              isRefresh: true,
                            );
                          },
                          child: const SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: 400,
                              child: EmptyBookingsWidget(),
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: context.colors.primary,
                        onRefresh: () async {
                          await context.read<MyBookingsCubit>().fetchBookings(
                            isRefresh: true,
                          );
                        },
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 200) {
                              context
                                  .read<MyBookingsCubit>()
                                  .loadMoreBookings();
                            }
                            return false;
                          },
                          child: MyBookingsListView(bookings: filteredBookings),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
