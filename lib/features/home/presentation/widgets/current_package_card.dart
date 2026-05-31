import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/features/home/data/models/subscribed_package_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';

class CurrentPackageCard extends StatelessWidget {
  final SubscribedPackageModel package;
  final VoidCallback? onUsePackage;

  const CurrentPackageCard({
    super.key,
    required this.package,
    this.onUsePackage,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return Container(
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
            // Patterns/Shadows similar to PackageCard
            Positioned(
              top: 0,
              left: 0,

              child: Image.asset(
                AppAssets.shadows_1,
                fit: BoxFit.cover,
                color: context.colors.primary,
                width: height * 0.23,
                height: height * 0.25,
              ),
            ),
            Positioned(
              bottom: 0,

              right: 0,
              child: Image.asset(
                AppAssets.shadows_2,
                color: context.colors.primary,
                width: height * 0.2,
                height: height * 0.22,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: width * 0.12,
                        height: width * 0.12,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.colors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          package.image,
                          color: context.colors.textTheme,
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.textPrimary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          DateFormat(
                            'dd - MM - yyyy',
                          ).format(package.expiryDate),
                          style: AppTextStyles.medium10.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(package.title, style: AppTextStyles.medium18),
                            SizedBox(height: context.screenHeight * 0.005),
                            SizedBox(
                              width: context.isMobile
                                  ? height * 0.25
                                  : width * 0.5,
                              child: Text(
                                package.description,
                                style: AppTextStyles.regular14.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            LocaleKeys.home_remaining.tr(),
                            style: AppTextStyles.regular10.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          Text(
                            '${package.remainingWashes}/${package.totalWashes}',
                            style: AppTextStyles.bold18.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.01),
                  GestureDetector(
                    onTap: onUsePackage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: context.colors.cardBackGround.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Text(
                            LocaleKeys.home_use_package.tr(),
                            style: AppTextStyles.medium14.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: context.colors.textPrimary,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.arrow_forward_ios,

                                size: 8,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
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
