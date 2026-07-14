import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final double maxRating;
  final double starSize;
  final Color? filledColor;
  final Color? unfilledColor;
  final bool showRatingValue;
  final TextStyle? ratingTextStyle;

  const RatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.starSize = 14,
    this.filledColor,
    this.unfilledColor,
    this.showRatingValue = false,
    this.ratingTextStyle,
  });

  double get _visualRating {
    final floor = rating.floorToDouble();
    final diff = rating - floor;
    if (diff >= 0.5) {
      return floor + 0.5;
    } else {
      return floor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating.toInt(), (index) {
          IconData iconData;
          Color color;

          if (index < rating.floor()) {
            iconData = Icons.star;
            color = filledColor ?? context.colors.warning;
          } else if (index < rating && (rating - index) >= 0.5) {
            iconData = Icons.star_half;
            color = filledColor ?? context.colors.warning;
          } else {
            iconData = Icons.star;
            color = unfilledColor ?? context.colors.contentDisabled;
          }

          return Icon(iconData, color: color, size: starSize);
        }),
        if (showRatingValue) ...[
          SizedBox(width: context.sw(4)),
          Text(
            '(${_visualRating.toStringAsFixed(1)})',
            style: ratingTextStyle ??
                AppTextStyles.regular12.copyWith(
                  color: context.colors.textTertiary,
                ),
          ),
        ],
      ],
    );
  }
}
