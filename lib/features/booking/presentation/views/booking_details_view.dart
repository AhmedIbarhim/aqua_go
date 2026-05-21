import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/features/my_cars/controllers/my_cars_cubit.dart';
import 'package:aqua_go/features/my_cars/data/models/my_car_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/car_selection_list.dart';
import '../widgets/additional_services_grid.dart';
import '../widgets/date_time_picker.dart';
import '../controllers/booking_cubit.dart';
import '../controllers/booking_state.dart';
import '../../../../core/route/app_router.dart';
import '../../../../core/helpers/shimmer_helper.dart';

class BookingDetailsView extends StatelessWidget {
  const BookingDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => locator<MyCarsCubit>()..getCars()),
      ],
      child: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, bookingState) {
          return Scaffold(
            backgroundColor: context.colors.screenBG,
            appBar: GenericAppBar(
              title: LocaleKeys.bookings_booking_details.tr(),
              hasBackground: true,
              backgroundImage: AppAssets.bookingHeaderImage,
              centerTitle: true,
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildContent(context, bookingState, width, height),
                  ),
                ),
                _buildBottomActionSheet(context, bookingState, width, height),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BookingState bookingState,
    double width,
    double height,
  ) {
    return Container(
      padding: EdgeInsets.all(width * 0.06),
      decoration: BoxDecoration(color: context.colors.themeColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            LocaleKeys.bookings_choose_car.tr(),
            isRequired: true,
          ),
          SizedBox(height: height * 0.02),
          BlocBuilder<MyCarsCubit, MyCarsState>(
            builder: (context, myCarsState) {
              if (myCarsState is MyCarsLoading ||
                  myCarsState is MyCarsInitial) {
                return ShimmerHelper.bookingCars(
                  onAddCar: () {
                    context.pushNamed(Routes.addVehicle).then((_) {
                      if (context.mounted) {
                        context.read<MyCarsCubit>().getCars();
                      }
                    });
                  },
                );
              }
              final cars = myCarsState is MyCarsLoaded
                  ? myCarsState.cars
                  : <MyCarModel>[];
              int? selectedCarIndex;
              if (bookingState.selectedCar != null) {
                selectedCarIndex = cars.indexWhere(
                  (c) => c.id == bookingState.selectedCar!.id,
                );
                if (selectedCarIndex == -1) selectedCarIndex = null;
              }

              return CarSelectionList(
                cars: cars,
                selectedCarIndex: selectedCarIndex,
                onCarSelected: (index) {
                  context.read<BookingCubit>().selectCar(cars[index]);
                },
                onAddCar: () {
                  context.pushNamed(Routes.addVehicle).then((_) {
                    if (context.mounted) {
                      context.read<MyCarsCubit>().getCars();
                    }
                  });
                },
              );
            },
          ),
          SizedBox(height: height * 0.03),
          _buildSectionTitle(LocaleKeys.bookings_additional_services.tr()),
          SizedBox(height: height * 0.02),
          AdditionalServicesGrid(
            selectedIndices: bookingState.selectedServiceIndices,
            onServiceToggled: (index) {
              context.read<BookingCubit>().toggleService(index);
            },
          ),
          SizedBox(height: height * 0.02),
          BookingDateTimePicker(
            initialDate: bookingState.selectedDate,
            initialTime: bookingState.selectedTime,
            onDateChanged: (date) {
              context.read<BookingCubit>().updateDateTime(
                date,
                bookingState.selectedTime,
              );
            },
            onTimeChanged: (time) {
              context.read<BookingCubit>().updateDateTime(
                bookingState.selectedDate,
                time,
              );
            },
          ),
          SizedBox(height: height * 0.04),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isRequired = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (isRequired)
          const Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),
        Text(title, style: AppTextStyles.regular16),
      ],
    );
  }

  Widget _buildBottomActionSheet(
    BuildContext context,
    BookingState bookingState,
    double width,
    double height,
  ) {
    final isComplete =
        bookingState.selectedCar != null &&
        bookingState.selectedDate != null &&
        bookingState.selectedTime != null;

    return BottomActionSheetContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                LocaleKeys.bookings_total.tr(),
                style: AppTextStyles.regular14.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                bookingState.selectedService?.price ?? '0.00',
                style: AppTextStyles.medium24,
              ),
              const SizedBox(width: 4),
              SvgPicture.asset(
                AppAssets.currency,
                width: width * 0.06,
                colorFilter: ColorFilter.mode(
                  context.colors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          CustomButton(
            text: LocaleKeys.bookings_book_now.tr(),
            enabled: isComplete,
            onPressed: isComplete
                ? () {
                    context.pushNamed(
                      Routes.bookingSummary,
                      arguments: BookingFlowArgs(
                        bookingCubit: context.read<BookingCubit>(),
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
