import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../data/models/complaint_model.dart';

class ComplaintRecordCard extends StatelessWidget {
  final ComplaintModel complaint;
  final VoidCallback onTap;

  const ComplaintRecordCard({
    super.key,
    required this.complaint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double sw(double width) => (width / 414) * context.screenWidth;
    double sh(double height) => (height / 896) * context.screenHeight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(sw(12)),
        decoration: BoxDecoration(
          color: context.colors.cardBackGround,
          border: Border.all(color: context.colors.borderSecondary),
          borderRadius: BorderRadius.circular(sw(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: sw(40),
                  height: sw(40),
                  padding: EdgeInsets.all(sw(8)),
                  decoration: BoxDecoration(
                    color: context.colors.defaultSubtle,
                    borderRadius: BorderRadius.circular(sw(8)),
                  ),
                  child: SvgPicture.asset(
                    AppAssets.document,
                    colorFilter: ColorFilter.mode(
                      context.colors.textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(width: sw(8)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${complaint.id.substring(0, 4)}.',
                      style: AppTextStyles.medium14.copyWith(
                        color: context.colors.contentSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          complaint.getDate(context),
                          style: AppTextStyles.regular12.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: sw(6)),
                          child: Text(
                            '|',
                            style: AppTextStyles.regular12.copyWith(
                              color: context.colors.borderSecondary,
                            ),
                          ),
                        ),
                        Text(
                          complaint.getTime(context),
                          style: AppTextStyles.regular12.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),

            Container(
              padding: EdgeInsets.symmetric(horizontal: sw(8), vertical: sh(4)),
              decoration: BoxDecoration(
                color: complaint.status.getBgColor(context),
                borderRadius: BorderRadius.circular(sw(16)),
              ),
              child: Text(
                complaint.status.translationKey.tr(),
                style: AppTextStyles.regular12.copyWith(
                  color: complaint.status.getTextColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
