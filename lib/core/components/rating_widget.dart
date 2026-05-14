import 'package:flutter/material.dart';

import '../extentions/context_extentions.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final double maxRating;
  final double starSize;
  final Color? filledColor;
  final Color? unfilledColor;

  const RatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.starSize = 14,
    this.filledColor,
    this.unfilledColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating.toInt(), (index) {
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
    );
  }
}
