import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/enums/gender_enum.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import 'gender_card.dart';

class GenderSelectionWidget extends StatelessWidget {
  final Gender selectedGender;
  final bool isEditing;
  final ValueChanged<Gender> onChanged;

  const GenderSelectionWidget({
    super.key,
    required this.selectedGender,
    required this.isEditing,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = 12.0;
    final scaleFactor = context.sw(1.0).clamp(0.8, 1.2);
    final cardHeight = 80.0 * scaleFactor;
    final iconSize = 48.0 * scaleFactor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.profile_gender.tr(),
          style: AppTextStyles.medium14.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GenderCard(
                label: context.isEn
                    ? Gender.male.nameEn()
                    : Gender.male.nameAr(),
                icon: AppAssets.male,
                isSelected: selectedGender == Gender.male,
                isEditing: isEditing,
                height: cardHeight,
                iconSize: iconSize,
                onTap: isEditing ? () => onChanged(Gender.male) : null,
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: GenderCard(
                label: context.isEn
                    ? Gender.female.nameEn()
                    : Gender.female.nameAr(),
                icon: AppAssets.female,
                isSelected: selectedGender == Gender.female,
                isEditing: isEditing,
                height: cardHeight,
                iconSize: iconSize,
                onTap: isEditing ? () => onChanged(Gender.female) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
