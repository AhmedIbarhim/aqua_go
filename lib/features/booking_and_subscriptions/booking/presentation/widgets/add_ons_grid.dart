import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../../core/extentions/context_extentions.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../core/components/custom_network_image.dart';
import '../../../shared/add_on_model.dart';

class AddOnsGrid extends StatelessWidget {
  final List<AddOnModel> addons;
  final Set<int> selectedIndices;
  final Function(int index) onServiceToggled;

  const AddOnsGrid({
    super.key,
    required this.addons,
    required this.selectedIndices,
    required this.onServiceToggled,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (addons.isEmpty) {
      return const SizedBox.shrink();
    }
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: width * 0.02,
        crossAxisSpacing: width * 0.02,
        childAspectRatio: 2.1,
      ),
      itemCount: addons.length,
      itemBuilder: (context, index) {
        final addon = addons[index];
        final isSelected = selectedIndices.contains(index);
        final title = context.isAr
            ? (addon.nameAr ?? addon.nameEn ?? '')
            : (addon.nameEn ?? addon.nameAr ?? '');
        final priceStr = addon.price.toStringAsFixed(2);
        final iconUrl = addon.imageUrl ?? '';

        return GestureDetector(
          onTap: () => onServiceToggled(index),
          child: _buildAddOnCard(
            context,
            title,
            priceStr,
            iconUrl,
            width,
            isSelected: isSelected,
          ),
        );
      },
    );
  }

  Widget _buildAddOnCard(
    BuildContext context,
    String title,
    String price,
    String icon,
    double width, {
    bool isSelected = false,
  }) {
    return Container(
      padding: EdgeInsets.all(width * 0.025),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colors.brandHover
            : context.colors.themeColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? context.colors.primary
              : context.colors.borderSecondary,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildIcon(icon, width * 0.09),
          SizedBox(width: width * 0.015),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.regular14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      price,
                      style: AppTextStyles.medium14.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                      AppAssets.currency,
                      width: width * 0.035,
                      colorFilter: ColorFilter.mode(
                        context.colors.textSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String url, double width) {
    if (url.isEmpty) {
      return SvgPicture.asset(AppAssets.fragant, width: width);
    }
    return SizedBox(
      width: width,
      height: width,
      child: CustomNetworkImage(url, fit: BoxFit.contain),
    );
  }
}
