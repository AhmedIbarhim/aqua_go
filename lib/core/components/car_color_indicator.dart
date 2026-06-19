import 'package:flutter/material.dart';

import '../extentions/context_extentions.dart';
import '../helpers/car_color_helper.dart';
import '../themes/app_text_styles.dart';

/// Generic car-color display: a colored dot plus the localized color name.
///
/// Single source of truth for rendering a vehicle's editable color across every
/// screen (my-cars, booking summary, booking details, complaints, etc.). Pass
/// the backend's raw [colorValue] string (e.g. "0xFFdc2626" / "#dc2626") and the
/// dot colour + localized name are derived through [car_color_helper].
class CarColorIndicator extends StatelessWidget {
  const CarColorIndicator({
    super.key,
    required this.colorValue,
    this.dotSize = 12,
    this.gap = 4,
    this.textStyle,
  });

  final String? colorValue;
  final double dotSize;
  final double gap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colorCode = parseVehicleColorCode(colorValue);
    final dotColor = Color(colorCode);
    final name = getLocalizedColorName(colorCode);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: context.colors.borderSecondary,
              width: 0.5,
            ),
          ),
        ),
        SizedBox(width: gap),
        Text(
          name,
          style:
              textStyle ??
              AppTextStyles.regular12.copyWith(
                color: context.colors.textSecondary,
              ),
        ),
      ],
    );
  }
}
