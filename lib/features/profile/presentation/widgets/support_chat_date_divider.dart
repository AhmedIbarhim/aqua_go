import 'package:flutter/material.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';

class SupportChatDateDivider extends StatelessWidget {
  final String date;

  const SupportChatDateDivider({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: sh(16)),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: context.colors.borderSecondary.withOpacity(0.3),
              thickness: 1,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sw(12)),
            child: Text(
              date,
              style: AppTextStyles.regular11.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: context.colors.borderSecondary.withOpacity(0.3),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
