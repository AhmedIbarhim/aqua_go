import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/complaint_model.dart';

class ComplaintDetailsDescriptionCard extends StatelessWidget {
  final ComplaintModel complaint;

  const ComplaintDetailsDescriptionCard({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    double sw(double width) => (width / 414) * MediaQuery.sizeOf(context).width;
    double sh(double height) =>
        (height / 896) * MediaQuery.sizeOf(context).height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_complaint_details.tr(),
          style: AppTextStyles.medium14,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: sh(120)),
          padding: EdgeInsets.all(sw(16)),
          decoration: BoxDecoration(
            color: context.colors.brandSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.colors.borderSecondary),
          ),
          child: Text(
            complaint.getDetails(context),
            style: AppTextStyles.regular14.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
