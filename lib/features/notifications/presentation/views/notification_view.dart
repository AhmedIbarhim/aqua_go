import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors_extension.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/notification_model.dart';
import '../widgets/empty_notifications_widget.dart';
import '../widgets/notifications_list_view.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List<NotificationModel> notifications = [
    NotificationModel(
      title: 'notification1',
      description: 'description1',
      createdAt: DateTime.now(),
      isRead: false,
      serviceDone: false,
    ),
    NotificationModel(
      title: 'notification2',
      description: 'description2',
      createdAt: DateTime.now(),
      isRead: false,
      serviceDone: true,
    ),
    NotificationModel(
      title: 'notification3',
      description: 'description3',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: false,
      serviceDone: false,
    ),
    NotificationModel(
      title: 'notification4',
      description: 'description4',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
      serviceDone: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: GenericAppBar(title: LocaleKeys.notifications_notifications.tr()),
      body: Container(
        height: height,
        width: width,

        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: notifications.isEmpty
            ? EmptyNotificationsWidget()
            : NotificationsListView(notifications: notifications),
      ),
    );
  }
}
