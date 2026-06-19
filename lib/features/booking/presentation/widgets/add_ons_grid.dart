import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/components/custom_network_image.dart';
import '../../../home/data/models/add_on_model.dart';

class AddOnsGrid extends StatelessWidget {
  final List<AddOnModel> addons;
  final Set<int> selectedIndices;
  final Function(int index) onServiceToggled;
  final bool isPackageFlow;

  const AddOnsGrid({
    super.key,
    required this.addons,
    required this.selectedIndices,
    required this.onServiceToggled,
    this.isPackageFlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (addons.isEmpty) return const SizedBox.shrink();

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

        // Package-specific: usage fraction
        String? fraction;
        int? remain;
        if (isPackageFlow &&
            addon.kind?.toLowerCase() == 'included' &&
            addon.maxQtyPerWash != null &&
            addon.maxQtyPerWash! > 0) {
          final used = addon.qty ?? 0;
          remain = (addon.maxQtyPerWash ?? 0) - used;
          final max = addon.maxQtyPerWash!;
          fraction = '$remain/$max';
        }

        return GestureDetector(
          onTap: () => onServiceToggled(index),
          child: Opacity(
            opacity: remain == 0 ? 0.5 : 1.0,
            child: _buildCard(
              context,
              addon,
              title,
              fraction,
              width,
              isSelected: isSelected,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    AddOnModel addon,
    String title,
    String? fraction,
    double width, {
    bool isSelected = false,
  }) {
    final iconUrl = addon.imageUrl ?? '';
    final priceStr = addon.price.toStringAsFixed(2);

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
          _buildIcon(iconUrl, width * 0.09),
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
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      priceStr,
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
                    if (fraction != null) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.borderSecondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          fraction,
                          style: AppTextStyles.regular12.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String url, double size) {
    if (url.isEmpty) {
      return SvgPicture.asset(AppAssets.fragant, width: size);
    }
    return SizedBox(
      width: size,
      height: size,
      child: CustomNetworkImage(url, fit: BoxFit.contain),
    );
  }
}
