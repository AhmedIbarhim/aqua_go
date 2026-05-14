import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/features/home/presentation/data/models/current_package_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'current_package_card.dart';

class CurrentPackageSection extends StatelessWidget {
  final CurrentPackageModel? currentPackage;
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
          Text(
            'home.current_package'.tr(),
            style: !context.isTablet
                ? AppTextStyles.bold16
                : AppTextStyles.bold18,
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
