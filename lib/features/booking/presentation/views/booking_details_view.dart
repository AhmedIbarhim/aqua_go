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

class BookingDetailsView extends StatefulWidget {
  const BookingDetailsView({super.key});

  @override
  State<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends State<BookingDetailsView> {
  int? selectedCarIndex;
  final Set<int> selectedServiceIndices = {};
  DateTime? selectedDate;
  String? selectedTime;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return BlocProvider.value(
      value: locator<MyCarsCubit>()..getCars(),
      child: Builder(
        builder: (context) {
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
                    child: _buildContent(context, width, height),
                  ),
                ),
                _buildBottomActionSheet(context, width, height),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, double width, double height) {
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
            builder: (context, state) {
              final cars = state is MyCarsLoaded ? state.cars : <MyCarModel>[];
              return CarSelectionList(
                cars: cars,
                selectedCarIndex: selectedCarIndex,
                onCarSelected: (index) {
                  setState(() {
                    selectedCarIndex = index;
                  });
                },
                onAddCar: () {
                  context.pushNamed(Routes.addVehicle);
                },
              );
            },
          ),
          SizedBox(height: height * 0.03),
          _buildSectionTitle(LocaleKeys.bookings_additional_services.tr()),
          SizedBox(height: height * 0.02),
          AdditionalServicesGrid(
            selectedIndices: selectedServiceIndices,
            onServiceToggled: (index) {
              setState(() {
                if (selectedServiceIndices.contains(index)) {
                  selectedServiceIndices.remove(index);
                } else {
                  selectedServiceIndices.add(index);
                }
              });
            },
          ),
          SizedBox(height: height * 0.02),
          BookingDateTimePicker(
            initialDate: selectedDate ?? DateTime.now(),
            initialTime: selectedTime,
            onDateChanged: (date) {
              setState(() {
                selectedDate = date;
              });
            },
            onTimeChanged: (time) {
              setState(() {
                selectedTime = time;
              });
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
    double width,
    double height,
  ) {
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
              Text('94.99', style: AppTextStyles.medium24),
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
            onPressed: () {
              context.pushNamed(Routes.bookingSummary);
            },
          ),
        ],
      ),
    );
  }
}
