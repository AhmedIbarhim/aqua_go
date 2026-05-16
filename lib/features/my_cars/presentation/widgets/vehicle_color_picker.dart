import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/components/custom_color_picker.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/helpers/car_color_helper.dart';

class VehicleColorPicker extends StatelessWidget {
  final Color? selectedColor;
  final ValueChanged<Color> onColorChanged;

  const VehicleColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  // static const List<Color> _availableColors = [
  //   Color(0xFFa97142), // Bronze
  //   Color(0xFFf97316), // Orange
  //   Color(0xFF4b5563), // Charcoal
  //   Color(0xFF9ca3af), // Gray
  //   Color(0xFFc0c0c0), // Silver
  //   Color(0xFFf5f5f0), // Pearl White
  //   Color(0xFFffffff), // White
  //   Color(0xFF0e0e0e), // Black
  //   Color(0xFF7c4a2d), // Brown
  //   Color(0xFFfacc15), // Yellow
  //   Color(0xFF15803d), // Green
  //   Color(0xFF7f1d1d), // Burgundy
  //   Color(0xFFdc2626), // Red
  //   Color(0xFF1e3a8a), // Dark Blue
  //   Color(0xFF2563eb), // Blue
  //   Color(0xFF7dd3fc), // Light Blue
  // ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemSize = (constraints.maxWidth - (7 * 8)) / 8;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.my_cars_color.tr(),
                  style: AppTextStyles.medium14.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: carColors.length,
                  itemBuilder: (context, index) {
                    final color = carColors[index];
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => onColorChanged(color),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? context.colors.primary
                                : (color == Colors.white
                                      ? Colors.grey.shade300
                                      : Colors.transparent),
                            width: isSelected ? 2 : 0.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        CustomColorPicker.show(
                          context,
                          initialColor: selectedColor ?? Colors.red,
                          onColorChanged: onColorChanged,
                          onSave: () => Navigator.pop(context),
                          onCancel: () => Navigator.pop(context),
                        );
                      },
                      child: Container(
                        width: itemSize,
                        height: itemSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const SweepGradient(
                            colors: [
                              Colors.orange,
                              Colors.yellow,
                              Colors.green,
                              Colors.blue,
                              Colors.indigo,
                              Colors.purple,
                              Colors.red,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            AppAssets.colorDropper,
                            height: itemSize * 0.6,
                            width: itemSize * 0.6,
                          ),
                        ),
                      ),
                    ),
                    if (selectedColor != null &&
                        !carColors.contains(selectedColor)) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: itemSize,
                        height: itemSize,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.colors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
