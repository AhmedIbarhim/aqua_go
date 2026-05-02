import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/notification_model.dart';
import 'notificaion_card.dart';

class NotificationsListView extends StatelessWidget {
  const NotificationsListView({super.key, required this.notifications});

  final List<NotificationModel> notifications;

  Map<String, List<NotificationModel>> _groupNotificationsByDate(
    BuildContext context,
  ) {
    final Map<String, List<NotificationModel>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final notification in notifications) {
      final date = notification.createdAt;
      final notificationDate = DateTime(date.year, date.month, date.day);

      String dateKey;
      if (notificationDate == today) {
        dateKey = LocaleKeys.notifications_today.tr();
      } else if (notificationDate == yesterday) {
        dateKey = LocaleKeys.notifications_yesterday.tr();
      } else {
        dateKey = DateFormat(
          'd MMMM, yyyy',
          context.locale.languageCode,
        ).format(notification.createdAt);
      }

      if (!groups.containsKey(dateKey)) {
        groups[dateKey] = [];
      }
      groups[dateKey]!.add(notification);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _groupNotificationsByDate(context);
    final dateKeys = groupedNotifications.keys.toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: dateKeys.length,
        itemBuilder: (context, index) {
          final dateKey = dateKeys[index];
          final group = groupedNotifications[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  dateKey,
                  style: AppTextStyles.regular14.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, itemIndex) =>
                    NotificationCard(notification: group[itemIndex]),
                separatorBuilder: (context, itemIndex) =>
                    const SizedBox(height: 12),
                itemCount: group.length,
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
