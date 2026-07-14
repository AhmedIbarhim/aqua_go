import 'package:flutter/material.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'support_chat_avatar.dart';

class SupportChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final String? status;

  const SupportChatBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: sh(8)),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMe) ...[
            const SupportChatAvatar(isAgent: false),
            SizedBox(width: sw(8)),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw(16),
                    vertical: sh(12),
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? context.colors.chatPrimary
                        : context.colors.chatSecondary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(sw(16)),
                      topRight: Radius.circular(sw(16)),
                      bottomLeft: !isMe ? Radius.circular(sw(16)) : Radius.zero,
                      bottomRight: !isMe
                          ? Radius.zero
                          : Radius.circular(sw(16)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.textPrimary.withValues(
                          alpha: 0.03,
                        ),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: AppTextStyles.regular14.copyWith(
                      color: context.colors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: sh(4)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw(4)),
                  child: Text(
                    time,
                    style: AppTextStyles.regular10.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isMe) ...[
            SizedBox(width: sw(8)),
            const SupportChatAvatar(isAgent: true),
          ],
        ],
      ),
    );
  }
}
