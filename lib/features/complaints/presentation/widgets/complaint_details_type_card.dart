import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/complaint_model.dart';

class ComplaintDetailsTypeCard extends StatelessWidget {
  final String category;

  const ComplaintDetailsTypeCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    double sw(double width) => (width / 414) * MediaQuery.sizeOf(context).width;
    double sh(double height) =>
        (height / 896) * MediaQuery.sizeOf(context).height;

    final categoryEnum = ComplaintCategory.fromString(category);
    final categoryText = categoryEnum.translationKey.tr();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_complaint_type.tr(),
          style: AppTextStyles.medium14,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: sw(16), vertical: sh(16)),
          decoration: BoxDecoration(
            color: context.colors.brandSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.colors.borderSecondary),
          ),
          child: Text(
            categoryText,
            style: AppTextStyles.regular14.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
