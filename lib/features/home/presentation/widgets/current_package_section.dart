import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/features/booking_and_subscriptions/subscriptions/data/models/subscription_response_model/subscription_response_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/route/routes.dart';
import '../../../../generated/locale_keys.g.dart';
import 'current_package_card.dart';

class CurrentPackageSection extends StatelessWidget {
  final SubscriptionResponseModel? currentPackage;
  final VoidCallback? onUsePackage;

  const CurrentPackageSection({
    super.key,
    this.currentPackage,
    this.onUsePackage,
  });

  @override
  Widget build(BuildContext context) {
    if (currentPackage == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                LocaleKeys.home_current_package.tr(),
                style: !context.isTablet
                    ? AppTextStyles.bold16
                    : AppTextStyles.bold18,
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed(Routes.packages);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      LocaleKeys.home_available_packages.tr(),
                      style: AppTextStyles.regular12.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: context.colors.primary,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CurrentPackageCard(
            package: currentPackage!,
            onUsePackage: onUsePackage,
          ),
        ],
      ),
    );
  }
}
