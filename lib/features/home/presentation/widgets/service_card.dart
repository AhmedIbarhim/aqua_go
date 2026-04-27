import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../data/models/service_model.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.serviceModel});

  final ServiceModel serviceModel;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: width - 48,
      height: height * 0.18,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceModel.title,
                              style: AppTextStyles.bold13.copyWith(
                                color: AppColors.white,
                              ),

                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              serviceModel.description,
                              style: AppTextStyles.regular12.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.right,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (serviceModel.oldPrice.isNotEmpty)
                              Text(
                                serviceModel.oldPrice,
                                style: AppTextStyles.regular14.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.5),
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppColors.white,
                                  decorationThickness: 0.5,
                                ),
                              ),
                            const SizedBox(width: 8),

                            Text(
                              serviceModel.price,
                              style: AppTextStyles.bold18.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            SvgPicture.asset(
                              AppAssets.currency,
                              width: 20,
                              height: 20,
                              // ignore: deprecated_member_use
                              color: AppColors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Image.asset(
                        serviceModel.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
