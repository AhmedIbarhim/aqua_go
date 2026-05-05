import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';

class AdditionalServicesGrid extends StatelessWidget {
  final Set<int> selectedIndices;
  final Function(int index) onServiceToggled;

  const AdditionalServicesGrid({
    super.key,
    required this.selectedIndices,
    required this.onServiceToggled,
  });

  static final List<Map<String, String>> additionalServices = [
    {'title': 'فواحة', 'price': '8.00', 'icon': AppAssets.fragant},
    {'title': 'مناديل', 'price': '8.00', 'icon': AppAssets.tissues},
    {'title': 'دعاسة (قطعتين)', 'price': '8.00', 'icon': AppAssets.pedals},
    {'title': 'مناديل مبللة', 'price': '8.00', 'icon': AppAssets.wibes},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.1,
      ),
      itemCount: additionalServices.length,
      itemBuilder: (context, index) {
        final service = additionalServices[index];
        final isSelected = selectedIndices.contains(index);
        return GestureDetector(
          onTap: () => onServiceToggled(index),
          child: _buildServiceCard(
            context,
            service['title']!,
            service['price']!,
            service['icon']!,
            isSelected: isSelected,
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String price,
    String icon, {
    bool isSelected = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isSelected ? context.colors.brandHover : context.colors.themeColor,
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
          SvgPicture.asset(
            icon,
            width: 40,
          ),
          const SizedBox(width: 8),
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
                      width: 14,
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
}
