import 'package:flutter/material.dart';
import '../themes/app_colors_extension.dart';

class CustomRadioWidget extends StatelessWidget {
  final bool isSelected;

  const CustomRadioWidget({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? context.colors.primary
              : context.colors.borderSecondary,
          width: 1.5,
        ),
        color: isSelected ? context.colors.brandSubtle : Colors.transparent,
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.primary,
                ),
              ),
            )
          : null,
    );
  }
}
