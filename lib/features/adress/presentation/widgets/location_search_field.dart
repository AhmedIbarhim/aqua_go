import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:svg_flutter/svg.dart';
import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';

import 'package:aqua_go/features/adress/data/models/place_prediction_model.dart';

class LocationSearchField extends StatelessWidget {
  final TextEditingController controller;
  final List<PlacePredictionModel> predictions;
  final bool showResults;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClear;
  final Function(String) onPredictionTap;

  const LocationSearchField({
    super.key,
    required this.controller,
    required this.predictions,
    required this.showResults,
    required this.onSearchChanged,
    required this.onClear,
    required this.onPredictionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: darkAppColors.themeColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: darkAppColors.textSecondary,
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: controller,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                style: AppTextStyles.regular14.copyWith(
                  color: lightAppColors.themeColor,
                ),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      AppAssets.search,
                      colorFilter: ColorFilter.mode(
                        lightAppColors.themeColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  suffixIcon: GestureDetector(
                    onTap: onClear,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        AppAssets.close,
                        colorFilter: ColorFilter.mode(
                          lightAppColors.themeColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  hintText: LocaleKeys.address_search_hint.tr(),
                  hintStyle: AppTextStyles.regular14.copyWith(
                    color: darkAppColors.contentSecondaryLight,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: onSearchChanged,
              ),
            ),
          ),
        ),
        if (showResults) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: darkAppColors.themeColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: darkAppColors.textSecondary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.address_search_results.tr(),
                      style: AppTextStyles.regular12.copyWith(
                        color: lightAppColors.themeColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...predictions.map((prediction) {
                      return _buildSearchResultItem(
                        context,
                        prediction.description,
                        false,
                        onTap: () => onPredictionTap(prediction.placeId),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchResultItem(
    BuildContext context,
    String title,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    title,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isSelected
                        ? AppTextStyles.medium14.copyWith(
                            color: darkAppColors.contentBlack,
                          )
                        : AppTextStyles.regular14.copyWith(
                            color: darkAppColors.contentSecondaryLight,
                          ),
                  ),
                ),

                Icon(
                  Icons.search,
                  color: isSelected ? Colors.black : Colors.white,
                  size: 18,
                ),
              ],
            ),
            if (!isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Divider(
                  color: darkAppColors.textSecondary,
                  height: 1,
                  thickness: 0.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
