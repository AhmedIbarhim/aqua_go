import 'package:aqua_go/core/components/vehicle_make_logo.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../../core/extentions/context_extentions.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/app_assets.dart';
import 'package:aqua_go/features/my_cars/data/models/my_car_model.dart';

class CarSelectionList extends StatefulWidget {
  final int? selectedCarIndex;
  final List<MyCarModel> cars;
  final Function(int index) onCarSelected;
  final VoidCallback onAddCar;

  const CarSelectionList({
    super.key,
    required this.selectedCarIndex,
    required this.cars,
    required this.onCarSelected,
    required this.onAddCar,
  });

  @override
  State<CarSelectionList> createState() => _CarSelectionListState();
}

class _CarSelectionListState extends State<CarSelectionList> {
  final GlobalKey _selectedCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.selectedCarIndex != null) {
      _scrollSelectedIntoView();
    }
  }

  @override
  void didUpdateWidget(covariant CarSelectionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCarIndex != oldWidget.selectedCarIndex &&
        widget.selectedCarIndex != null) {
      _scrollSelectedIntoView();
    }
  }

  void _scrollSelectedIntoView() {
    // ensureVisible operates on render geometry, so it reveals the selected
    // card correctly in both ar (RTL) and en (LTR) with no direction handling.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _selectedCardKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      height: height * 0.14,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.cars.length + 1,
        separatorBuilder: (context, index) => SizedBox(width: width * 0.02),
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: widget.onAddCar,
              child: _buildAddCarCard(context, width, height),
            );
          }
          final car = widget.cars[index - 1];
          final isSelected = widget.selectedCarIndex == index - 1;
          return GestureDetector(
            key: isSelected ? _selectedCardKey : null,
            onTap: () => widget.onCarSelected(index - 1),
            child: _buildCarCard(
              context,
              car,
              width,
              height,
              isSelected: isSelected,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarCard(
    BuildContext context,
    MyCarModel car,
    double width,
    double height, {
    bool isSelected = false,
  }) {
    return Container(
      width: width * 0.28,
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colors.brandHover
            : context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: context.colors.primary) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: isSelected ? 1.0 : 0.9,
            child: VehicleMakeLogo(
              logoUrl: car.logoUrl,
              colorEditable: car.carMake?.colorEditable ?? false,
              size: height * 0.055,
            ),
          ),
          SizedBox(height: height * 0.01),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              context.isEn
                  ? '${car.carMake?.vehicleMakeName.nameEn} ${car.carModel?.vehicleModelName.nameEn}'
                  : '${car.carMake?.vehicleMakeName.nameAr} ${car.carModel?.vehicleModelName.nameAr}',
              style: AppTextStyles.regular12.copyWith(
                color: isSelected
                    ? context.colors.textPrimary
                    : context.colors.textTertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCarCard(BuildContext context, double width, double height) {
    return Container(
      width: width * 0.28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderSecondary),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.addCarIcon,
            width: width * 0.1,
            colorFilter: ColorFilter.mode(
              context.colors.textPrimary,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: height * 0.01),
          Text(
            LocaleKeys.bookings_add_car.tr(context: context),
            style: AppTextStyles.medium12.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
