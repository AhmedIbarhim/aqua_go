import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/themes/app_colors_extension.dart';
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
      width: width - 30,
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
                AppAssets.shadows_3,
                fit: BoxFit.cover,
                color: context.colors.primary,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: width * 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              serviceModel.title,
                              style: AppTextStyles.bold16,

                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              serviceModel.description,
                              style: AppTextStyles.regular12.copyWith(
                                color: context.colors.textSecondary,
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
                                  color: context.colors.textPrimary.withValues(
                                    alpha: 0.5,
                                  ),
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: context.colors.textPrimary,
                                  decorationThickness: 0.9,
                                ),
                              ),
                            const SizedBox(width: 8),

                            Text(
                              serviceModel.price,
                              style: AppTextStyles.bold18,
                            ),
                            const SizedBox(width: 4),
                            SvgPicture.asset(
                              AppAssets.currency,
                              width: 20,
                              height: 20,
                              // ignore: deprecated_member_use
                              color: context.colors.textPrimary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: width * 0.43,
                    height: height * 0.26,
                    child: Image.asset(
                      serviceModel.image,
                      fit: BoxFit.fill,
                      color: context.isDarkTheme
                          ? darkAppColors.primary
                          : darkAppColors.themeColor,
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
