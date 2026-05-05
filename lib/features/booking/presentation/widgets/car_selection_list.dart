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
      name: 'تويوتا',
      model: 'لاند كروزر',
      year: '2022',
      image: AppAssets.demoLandcroser,
      boardNumber: '1234',
      typeImage: AppAssets.demoToyota,
    ),
    MyCarModel(
      name: 'مرسيدس',
      model: 'جي كلاس',
      year: '2023',
      image: AppAssets.myCar,
      boardNumber: '5678',
      typeImage: AppAssets.demoToyota,
    ),
    MyCarModel(
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
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: myCars.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: onAddCar,
              child: _buildAddCarCard(context),
            );
          }
          final car = myCars[index - 1];
          final isSelected = selectedCarIndex == index - 1;
          return GestureDetector(
            onTap: () => onCarSelected(index - 1),
            child: _buildCarCard(context, car, isSelected: isSelected),
          );
        },
      ),
    );
  }

  Widget _buildCarCard(
    BuildContext context,
    MyCarModel car, {
    bool isSelected = false,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      height: MediaQuery.of(context).size.height * 0.15,
      padding: const EdgeInsets.all(12),
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
              height: 40,
              width: 60,
              fit: BoxFit.fitWidth,
            ),
          ),
          const SizedBox(height: 8),
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

  Widget _buildAddCarCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      height: MediaQuery.of(context).size.height * 0.15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderSecondary),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.addCarIcon,
            width: 40,
            colorFilter: ColorFilter.mode(
              context.colors.textPrimary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 8),
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
