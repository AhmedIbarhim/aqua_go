import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../controllers/notifications_cubit/notifications_cubit.dart';
import '../../data/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationsCubit>().markAsRead(notification.id);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: !notification.serviceDone
              ? context.colors.cardBackGround
              : context.colors.brandHover,
          borderRadius: BorderRadius.circular(16),
          border: !notification.isRead
              ? Border.all(
                  color: context.colors.primary.withValues(alpha: 0.3),
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: !notification.serviceDone
                    ? context.colors.defaultSubtle
                    : context.colors.themeOpositeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Opacity(
                opacity: 0.8,
                child: SvgPicture.asset(
                  !notification.serviceDone
                      ? AppAssets.notification
                      : AppAssets.notificationActive,
                  width: 20,
                  height: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.getLocalizedTitle(context.locale.languageCode),
                          style: AppTextStyles.medium16.copyWith(
                            color: context.colors.contentSecondaryLight,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: context.colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.getLocalizedBody(context.locale.languageCode),
                    style: AppTextStyles.regular14.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        DateFormat.jm(
                          context.locale.languageCode,
                        ).format(notification.createdAt),
                        style: AppTextStyles.regular12.copyWith(
                          color: context.colors.contentDisabled,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
