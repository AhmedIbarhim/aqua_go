import 'package:aqua_go/features/notifications/data/models/notification_model.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsSuccess extends NotificationsState {
  final List<NotificationModel> notifications;
  final String? nextCursor;
  final bool hasReachedMax;
  final int unreadCount;

  const NotificationsSuccess({
    required this.notifications,
    this.nextCursor,
    required this.hasReachedMax,
    required this.unreadCount,
  });

  NotificationsSuccess copyWith({
    List<NotificationModel>? notifications,
    String? nextCursor,
    bool? hasReachedMax,
    int? unreadCount,
  }) {
    return NotificationsSuccess(
      notifications: notifications ?? this.notifications,
      nextCursor: nextCursor ?? this.nextCursor,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [notifications, nextCursor, hasReachedMax, unreadCount];
}

class NotificationsFailure extends NotificationsState {
  final String errMessage;

  const NotificationsFailure(this.errMessage);

  @override
  List<Object?> get props => [errMessage];
}
