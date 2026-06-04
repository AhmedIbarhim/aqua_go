import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/features/my_cars/data/models/my_car_model.dart';
import 'package:aqua_go/features/my_cars/presentation/widgets/car_make_logo_network_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg_flutter.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';

class MyCarCard extends StatelessWidget {
  final MyCarModel car;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MyCarCard({super.key, required this.car, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      width: double.infinity,
      height: height * 0.23,
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Container
          Container(
            height: height * 0.12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Image.asset(AppAssets.shadows_1, width: width * 0.7),
                ),
                // Car Image
                Center(
                  child: SizedBox(
                    height: height * 0.07,
                    child: Image.asset(
                      AppAssets.myCar,
                      color: Color(car.colorCode),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                // Brand Logo
                Positioned(
                  right: width * 0.01,
                  top: 0,
                  child: SizedBox(
                    height: height * 0.05,
                    width: height * 0.05,
                    child: CarMakeNetworkLogo(logoUrl: car.typeImage),
                  ),
                ),
                // Edit and Delete Icons
                Positioned(
                  left: width * 0.03,
                  top: height * 0.015,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onEdit,
                        child: SvgPicture.asset(
                          AppAssets.edit,
                          width: width * 0.05,
                          colorFilter: ColorFilter.mode(
                            context.colors.themeOpositeColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.04),
                      GestureDetector(
                        onTap: () {
                          context.showWarningAlert(
                            primaryButtonText: LocaleKeys.delete_confirm.tr(),
                            title: LocaleKeys.delete_confirm.tr(),
                            message: LocaleKeys.my_cars_delete_message.tr(),
                            onPrimaryPressed: () {
                              Navigator.pop(context);
                              onDelete?.call();
                            },
                          );
                        },
                        child: SvgPicture.asset(
                          AppAssets.remove,
                          width: width * 0.05,
                          colorFilter: ColorFilter.mode(
                            lightAppColors.error,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: height * 0.008),
          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.01),
            child: Text(
              context.isAr
                  ? "${car.carMake?.vehicleMakeName.nameAr} ${car.carModel?.vehicleModelName.nameAr}"
                  : "${car.carMake?.vehicleMakeName.nameEn} ${car.carModel?.vehicleModelName.nameEn}",
              style: AppTextStyles.medium14,
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: height * 0.005),
          // Specs Row
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildSpecItem(
                context,
                text: car.modelYear.toString(),
                icon: AppAssets.calender,
              ),
              _buildDivider(context),
              _buildSpecItem(
                context,
                text: car.colorName,
                icon: AppAssets.colorSwatch,
              ),
              _buildDivider(context),

              _buildSpecItem(
                context,
                text: car.boardNumber,
                icon: AppAssets.note,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(
    BuildContext context, {
    required String text,
    required String icon,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          icon,
          width: width * 0.045,
          height: width * 0.045,
          colorFilter: ColorFilter.mode(
            context.colors.contentSecondaryLight,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: width * 0.01),

        Text(
          text,
          style: AppTextStyles.regular12.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.02),
      width: 1,
      height: height * 0.015,
      color: context.colors.borderSecondary,
    );
  }
}
