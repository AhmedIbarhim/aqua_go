import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../home/presentation/data/models/package_model.dart';

class BookingPackageDetailsContent extends StatelessWidget {
  final PackageModel packageModel;
  final VoidCallback onBuy;

  const BookingPackageDetailsContent({
    super.key,
    required this.packageModel,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image
        SizedBox(
          height: height * 0.25,
          width: width * 0.75,
          child: SvgPicture.asset(AppAssets.onboarding1, fit: BoxFit.fill),
        ),
        SizedBox(height: height * 0.05),

        // Details Container
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(width * 0.03),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      packageModel.title,
                      style: AppTextStyles.semiBold24,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.02,
                      vertical: width * 0.02,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.themeOpositeColor.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${LocaleKeys.booking_package_duration.tr()} ${packageModel.duration}',
                          style: AppTextStyles.medium12,
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.timer_outlined, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                packageModel.description,
                style: AppTextStyles.regular16.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                LocaleKeys.booking_package_price.tr(),
                style: AppTextStyles.regular14.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(packageModel.price, style: AppTextStyles.medium24),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    AppAssets.currency,
                    colorFilter: ColorFilter.mode(
                      context.colors.themeOpositeColor,
                      BlendMode.srcIn,
                    ),
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: height * 0.02),

        // Subscribe Button
        CustomButton(
          text: LocaleKeys.booking_package_buy.tr(),
          onPressed: onBuy,
        ),
      ],
    );
  }
}
