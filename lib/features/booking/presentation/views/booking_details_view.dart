import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/generic_app_bar.dart';
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
    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.bookings_booking_details.tr(),
        hasBackground: true,
        backgroundImage: AppAssets.bookingHeaderImage,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildContent(context)),
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),
          _buildBottomActionSheet(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: context.colors.themeColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            LocaleKeys.bookings_choose_car.tr(),
            isRequired: true,
          ),
          const SizedBox(height: 16),
          CarSelectionList(
            selectedCarIndex: selectedCarIndex,
            onCarSelected: (index) {
              setState(() {
                selectedCarIndex = index;
              });
            },
            onAddCar: () {
              // TODO: Navigate to Add Car view
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(LocaleKeys.bookings_additional_services.tr()),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 30),
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

  Widget _buildBottomActionSheet(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        decoration: BoxDecoration(color: context.colors.screenBG),
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
                const Text('94.99', style: AppTextStyles.medium24),

                SvgPicture.asset(
                  AppAssets.currency,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    context.colors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: LocaleKeys.bookings_book_now.tr(),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
