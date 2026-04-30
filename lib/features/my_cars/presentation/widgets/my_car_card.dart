import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/features/my_cars/data/models/my_car_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:svg_flutter/svg_flutter.dart';

import '../../../../core/themes/app_colors_extension.dart'
    show AppThemeExtension;
import '../../../../core/themes/app_text_styles.dart';

class MyCarCard extends StatelessWidget {
  final MyCarModel car;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MyCarCard({super.key, required this.car, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      height: height * 0.23,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Container
          Container(
            height: height * 0.13,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colors.defaultSubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Car Image
                Center(child: Image.asset(car.image, fit: BoxFit.contain)),
                // Toyota Logo
                Positioned(
                  right: 4,
                  top: 4,
                  child: Image.asset(
                    car.typeImage,
                    // width: 42,
                    // height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                // Edit and Delete Icons
                Positioned(
                  left: 12,
                  top: 12,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onEdit,
                        child: SvgPicture.asset(
                          AppAssets.edit,
                          colorFilter: ColorFilter.mode(
                            context.colors.textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: onDelete,
                        child: SvgPicture.asset(AppAssets.remove),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              "${car.name} ${car.model}",
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          // Specs Row
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildSpecItem(context, text: car.year, icon: AppAssets.manfYear),
              _buildDivider(context),
              _buildSpecItem(
                context,
                text: car.color,
                icon: AppAssets.colorSwatch,
              ),
              _buildDivider(context),

              _buildSpecItem(
                context,
                text: car.boardNumber,
                icon: AppAssets.boardNum,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          icon,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(
            context.colors.contentSecondaryLight,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 4),

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 1,
      height: 16,
      color: context.colors.borderSecondary,
    );
  }
}
