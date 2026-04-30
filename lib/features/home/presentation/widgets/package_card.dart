import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../booking/presentation/widgets/booking_package_bottom_sheet.dart';
import '../data/models/package_model.dart';

class PackageCard extends StatelessWidget {
  const PackageCard({
    super.key,
    required this.packageModel,
    this.atHome = true,
  });

  final PackageModel packageModel;
  final bool? atHome;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        BookingPackageBottomSheet.show(context, packageModel: packageModel);
      },
      child: Container(
        width: atHome == true ? width - 96 : width,

        decoration: BoxDecoration(
          color: context.colors.screenBG,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.primary, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,

                child: Image.asset(
                  AppAssets.shadows_1,
                  fit: BoxFit.cover,
                  color: context.colors.primary,
                ),
              ),

              Positioned(
                bottom: 0,

                right: 0,
                child: Image.asset(
                  AppAssets.shadows_2,
                  color: context.colors.primary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gift Icon Box
                        Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.colors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            packageModel.image,
                            color: context.colors.textTheme,
                          ),
                        ),
                        // Duration Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.textPrimary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'لمدة : ${packageModel.duration}',
                            style: AppTextStyles.medium12.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Title and Subtitle
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              packageModel.title,
                              style: AppTextStyles.medium16,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              packageModel.description,
                              style: AppTextStyles.regular12.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              packageModel.price,
                              style: AppTextStyles.bold18,
                            ),
                            const SizedBox(width: 4),
                            SvgPicture.asset(
                              AppAssets.currency,
                              width: 24,
                              height: 24,
                              // ignore: deprecated_member_use
                              color: context.colors.textPrimary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
