import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../features/my_cars/data/models/my_car_model.dart';

class CarSelectionList extends StatelessWidget {
  final int? selectedCarIndex;
  final Function(int index) onCarSelected;
  final VoidCallback onAddCar;

  const CarSelectionList({
    super.key,
    required this.selectedCarIndex,
    required this.onCarSelected,
    required this.onAddCar,
  });

  static final List<MyCarModel> myCars = [
    MyCarModel(
      id: '',
      name: 'تويوتا',
      model: 'لاند كروزر',
      year: '2022',
      image: AppAssets.demoLandcroser,
      boardNumber: '1234',
      typeImage: AppAssets.demoToyota,
    ),
    MyCarModel(
      id: '',
      name: 'مرسيدس',
      model: 'جي كلاس',
      year: '2023',
      image: AppAssets.myCar,
      boardNumber: '5678',
      typeImage: AppAssets.demoToyota,
    ),
    MyCarModel(
      id: '',
      name: 'بي ام دبليو',
      model: 'الفئة الخامسة',
      year: '2024',
      image: AppAssets.myCar,
      boardNumber: '9012',
      typeImage: AppAssets.demoToyota,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: height * 0.14,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: myCars.length + 1,
        separatorBuilder: (context, index) => SizedBox(width: width * 0.02),
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: onAddCar,
              child: _buildAddCarCard(context, width, height),
            );
          }
          final car = myCars[index - 1];
          final isSelected = selectedCarIndex == index - 1;
          return GestureDetector(
            onTap: () => onCarSelected(index - 1),
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
            opacity: isSelected ? 1.0 : 0.5,
            child: Image.asset(
              car.typeImage,
              height: height * 0.045,
              width: width * 0.15,
              fit: BoxFit.fitWidth,
            ),
          ),
          SizedBox(height: height * 0.01),
          Text(
            '${car.name} ${car.model}',
            style: AppTextStyles.regular12.copyWith(
              color: isSelected
                  ? context.colors.textPrimary
                  : context.colors.contentDisabled,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
            LocaleKeys.bookings_add_car.tr(),
            style: AppTextStyles.medium12.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
