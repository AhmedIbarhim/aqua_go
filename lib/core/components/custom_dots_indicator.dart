import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

import '../extentions/context_extentions/responsive_extension.dart';
import '../extentions/context_extentions/theme_extension.dart';

class CustomDotsIndicator extends StatelessWidget {
  const CustomDotsIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return DotsIndicator(
      dotsCount: count,
      position: currentIndex.toDouble(),
      decorator: DotsDecorator(
        activeColor: context.colors.contentSecondaryLight,
        color: context.colors.contentSecondary,
        size: Size(context.screenWidth * 0.015, context.screenWidth * 0.015),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.screenWidth * 0.015),
        ),
        spacing: EdgeInsets.all(context.screenWidth * 0.01),
        activeSize: Size(
          context.screenWidth * 0.015,
          context.screenWidth * 0.015,
        ),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.screenWidth * 0.015),
        ),
      ),
    );
  }
}
