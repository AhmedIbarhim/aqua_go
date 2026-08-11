import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../data/models/thread_model.dart';

class ChatThreadCard extends StatelessWidget {
  final ThreadModel thread;
  final VoidCallback onTap;

  const ChatThreadCard({super.key, required this.thread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    final hasUnread = thread.unreadCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(sw(12)),
        decoration: BoxDecoration(
          color: context.colors.cardBackGround,
          border: Border.all(color: context.colors.borderSecondary),
          borderRadius: BorderRadius.circular(sw(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    thread.displaySubject(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.medium14.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: sw(8)),
                _StatusChip(thread: thread),
              ],
            ),
            SizedBox(height: sh(8)),
            Row(
              children: [
                _CategoryChip(thread: thread),
                const Spacer(),
                Text(
                  thread.lastActivityLabel(context),
                  style: AppTextStyles.regular11.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
            if ((thread.lastMessagePreview ?? '').trim().isNotEmpty) ...[
              SizedBox(height: sh(8)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      thread.lastMessagePreview!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.regular12.copyWith(
                        color: hasUnread
                            ? context.colors.textPrimary
                            : context.colors.textSecondary,
                        fontWeight: hasUnread
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (hasUnread) ...[
                    SizedBox(width: sw(8)),
                    _UnreadBadge(count: thread.unreadCount),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ThreadModel thread;
  const _StatusChip({required this.thread});

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw(8), vertical: sh(4)),
      decoration: BoxDecoration(
        color: thread.status.getBgColor(context),
        borderRadius: BorderRadius.circular(sw(16)),
      ),
      child: Text(
        thread.status.translationKey.tr(context: context),
        style: AppTextStyles.regular11.copyWith(
          color: thread.status.getTextColor(context),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final ThreadModel thread;
  const _CategoryChip({required this.thread});

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw(8), vertical: sh(3)),
      decoration: BoxDecoration(
        color: context.colors.defaultSubtle,
        borderRadius: BorderRadius.circular(sw(8)),
      ),
      child: Text(
        thread.category.translationKey.tr(context: context),
        style: AppTextStyles.regular11.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: AppTextStyles.regular11.copyWith(
          color: context.colors.contentBlack,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
