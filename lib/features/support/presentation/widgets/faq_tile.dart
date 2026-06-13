import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extentions/responsive_extension.dart';
import '../../../../core/extentions/context_extentions/theme_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../data/models/Faq_model.dart';

class FaqTile extends StatelessWidget {
  final FaqModel faq;
  final bool isExpanded;
  final VoidCallback onTap;

  const FaqTile({
    super.key,
    required this.faq,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: sw(16), vertical: sh(16)),
        decoration: BoxDecoration(
          color: context.colors.cardBackGround,
          border: Border.all(
            color: isExpanded
                ? context.colors.borderSecondary
                : context.colors.borderSecondary.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(sw(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    faq.question,
                    style: AppTextStyles.medium16.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: sw(12)),
                Icon(
                  isExpanded ? Icons.remove : Icons.add,
                  color: context.colors.primary,
                  size: sw(20),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: sh(16)),
                  ...faq.answerBullets.map(
                    (bullet) => Padding(
                      padding: EdgeInsets.only(bottom: sh(12)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: sh(6)),
                            child: Container(
                              width: sw(5),
                              height: sw(5),
                              decoration: BoxDecoration(
                                color: context.colors.textSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          SizedBox(width: sw(8)),
                          Expanded(
                            child: Text(
                              bullet,
                              style: AppTextStyles.regular14.copyWith(
                                color: context.colors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}
