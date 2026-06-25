import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/components/custom_loading_indicator.dart';
import '../../../../core/components/error_retry_widget.dart';
import '../../../../generated/locale_keys.g.dart';
import '../controllers/notifications_cubit/notifications_cubit.dart';
import '../controllers/notifications_cubit/notifications_state.dart';
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

class NotificationViewBody extends StatefulWidget {
  const NotificationViewBody({super.key});

  @override
  State<NotificationViewBody> createState() => _NotificationViewBodyState();
}

class _NotificationViewBodyState extends State<NotificationViewBody> {
  bool _hasMarkedAsRead = false;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.sizeOf(context).height;
    var width = MediaQuery.sizeOf(context).width;

    return BlocListener<NotificationsCubit, NotificationsState>(
      listener: (context, state) {
        if (state is NotificationsSuccess &&
            state.unreadCount > 0 &&
            !_hasMarkedAsRead) {
          _hasMarkedAsRead = true;
          context.read<NotificationsCubit>().markAllAsRead();
        }
      },
      child: Scaffold(
        appBar: GenericAppBar(
          title: LocaleKeys.notifications_notifications.tr(context: context),
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
                return ErrorRetryWidget(
                  errorMessage: state.errMessage,
                  onRetry: () =>
                      context.read<NotificationsCubit>().fetchNotifications(),
                );
              } else if (state is NotificationsSuccess) {
                final notifications = state.notifications;
                if (notifications.isEmpty) {
                  return const EmptyNotificationsWidget();
                }

                return RefreshIndicator(
                  color: context.colors.primary,
                  onRefresh: () async {
                    setState(() {
                      _hasMarkedAsRead = false;
                    });
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
      ),
    );
  }
}
