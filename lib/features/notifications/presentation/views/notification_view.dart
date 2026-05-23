import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/components/custom_loading_indicator.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../controllers/notifications_cubit/notifications_cubit.dart';
import '../../controllers/notifications_cubit/notifications_state.dart';
import '../widgets/empty_notifications_widget.dart';
import '../widgets/notifications_list_view.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<NotificationsCubit>()..fetchNotifications(),
      child: const NotificationViewBody(),
    );
  }
}

class NotificationViewBody extends StatelessWidget {
  const NotificationViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: GenericAppBar(
        title: LocaleKeys.notifications_notifications.tr(),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsSuccess &&
                  state.notifications.isNotEmpty &&
                  state.unreadCount > 0) {
                return IconButton(
                  tooltip: 'Mark all as read',
                  icon: Icon(Icons.done_all, color: context.colors.primary),
                  onPressed: () {
                    context.read<NotificationsCubit>().markAllAsRead();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading) {
              return const Center(child: CustomLoadingIndicator(size: 100));
            } else if (state is NotificationsFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errMessage,
                      style: AppTextStyles.medium16.copyWith(
                        color: context.colors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                      ),
                      onPressed: () {
                        context.read<NotificationsCubit>().fetchNotifications();
                      },
                      child: Text(
                        'Retry',
                        style: AppTextStyles.medium14.copyWith(
                          color: context.colors.themeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is NotificationsSuccess) {
              final notifications = state.notifications;
              if (notifications.isEmpty) {
                return const EmptyNotificationsWidget();
              }

              return RefreshIndicator(
                color: context.colors.primary,
                onRefresh: () async {
                  await context.read<NotificationsCubit>().fetchNotifications(
                    isRefresh: true,
                  );
                },
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200) {
                      context
                          .read<NotificationsCubit>()
                          .loadMoreNotifications();
                    }
                    return false;
                  },
                  child: NotificationsListView(notifications: notifications),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
