import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/features/subscriptions/data/models/subscription_response_model/subscription_response_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/route/routes.dart';
import '../../../../generated/locale_keys.g.dart';
import 'current_package_card.dart';

class CurrentPackageSection extends StatefulWidget {
  final List<SubscriptionResponseModel> subscribedPackages;
  final Function(SubscriptionResponseModel package)? onUsePackage;

  const CurrentPackageSection({
    super.key,
    required this.subscribedPackages,
    this.onUsePackage,
  });

  @override
  State<CurrentPackageSection> createState() => _CurrentPackageSectionState();
}

class _CurrentPackageSectionState extends State<CurrentPackageSection> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.subscribedPackages.isEmpty) return const SizedBox.shrink();

    final height = MediaQuery.sizeOf(context).height;
    final cardHeight = context.isTablet ? height * 0.2 : 210.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
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
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: cardHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.subscribedPackages.length,

            itemBuilder: (context, index) {
              final package = widget.subscribedPackages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CurrentPackageCard(
                  package: package,
                  onUsePackage: () => widget.onUsePackage?.call(package),
                ),
              );
            },
          ),
        ),
        if (widget.subscribedPackages.length > 1) ...[
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
