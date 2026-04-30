import 'dart:ui' as ui;
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/custom_button.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../home/presentation/data/models/package_model.dart';
import 'booking_package_success_alert.dart';

class BookingPackageBottomSheet extends StatelessWidget {
  final PackageModel packageModel;

  const BookingPackageBottomSheet({super.key, required this.packageModel});

  static Future<T?> show<T>(
    BuildContext context, {
    required PackageModel packageModel,
  }) {
    return showModalBottomSheet<T>(
      context: context,

      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.pop(),
                  child: const SizedBox.expand(),
                ),
              ),
              BookingPackageBottomSheet(packageModel: packageModel),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: 64,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      child: Icon(Icons.arrow_back, size: 24),
                    ),
                  ),
                  Text(
                    LocaleKeys.booking_package_package_details.tr(),
                    style: AppTextStyles.regular20,
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 48),

              // Image
              SizedBox(
                height: 200,
                width: 316,
                child: SvgPicture.asset(
                  AppAssets.onboarding1,
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(height: 48),

              // Details Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
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
                            style: AppTextStyles.semiBold24.copyWith(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
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
                                style: AppTextStyles.medium12.copyWith(),
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

                    // Total
                    Text(
                      LocaleKeys.booking_package_total.tr(),
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
              const SizedBox(height: 16),

              // Subscribe Button
              CustomButton(
                text: LocaleKeys.booking_package_buy.tr(),
                onPressed: () {
                  context.pop();
                  BookingPackageSuccessAlert.show(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
