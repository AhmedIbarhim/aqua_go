import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../data/models/service_model.dart';

import '../../../../core/helpers/fetch_user_data_helper.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.serviceModel});

  final ServiceModel serviceModel;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        if (FetchUserData.isGuest()) {
          FetchUserData.promptGuestToLogin(context);
        } else {
          context.pushNamed(Routes.bookingLocation, arguments: serviceModel);
        }
      },
      child: Container(
        width: width,
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
                  width: width * 0.45,
                  height: width * 0.45,
                ),
              ),

              Padding(
                padding: EdgeInsets.all(width * 0.035),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.isEn
                                    ? serviceModel.rawName.nameEn
                                    : serviceModel.rawName.nameAr,
                                style: AppTextStyles.bold16,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.isEn
                                    ? serviceModel.rawDescription.descEn
                                    : serviceModel.rawDescription.descAr,
                                style: AppTextStyles.regular12.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          if (serviceModel.price.isNotEmpty) ...[
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (serviceModel.oldPrice.isNotEmpty) ...[
                                  Text(
                                    serviceModel.oldPrice,
                                    style: AppTextStyles.regular12.copyWith(
                                      color: context.colors.textPrimary
                                          .withValues(alpha: 0.5),
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor:
                                          context.colors.textPrimary,
                                      decorationThickness: 0.9,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  serviceModel.priceMinor != null
                                      ? serviceModel.priceMinor.toString()
                                      : serviceModel.price,
                                  style: AppTextStyles.bold18,
                                ),
                                const SizedBox(width: 4),
                                SvgPicture.asset(
                                  AppAssets.currency,
                                  width: 18,
                                  height: 18,
                                  // ignore: deprecated_member_use
                                  color: context.colors.textPrimary,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Transform.flip(
                        flipX: context.isEn,
                        child: Image.asset(
                          serviceModel.image,
                          fit: BoxFit.fill,
                          color: context.colors.primary,
                        ),
                      ),
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
