import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_model.dart';
import '../../data/repos/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;
  bool _isLoadingMore = false;

  NotificationsCubit(this._repository) : super(NotificationsInitial());

  Future<void> fetchNotifications({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(NotificationsLoading());
    }

    final countResult = await _repository.getUnreadCount();
    int unreadCount = 0;
    countResult.fold((failure) => null, (count) => unreadCount = count);

    final notificationsResult = await _repository.getNotifications(limit: 20);

    notificationsResult.fold(
      (failure) => emit(NotificationsFailure(failure.message)),
      (page) {
        emit(
          NotificationsSuccess(
            notifications: page.items,
            nextCursor: page.nextCursor,
            hasReachedMax: page.nextCursor == null || page.nextCursor!.isEmpty,
            unreadCount: unreadCount,
          ),
        );
      },
    );
  }

  Future<void> loadMoreNotifications() async {
    final currentState = state;
    if (currentState is! NotificationsSuccess ||
        currentState.hasReachedMax ||
        _isLoadingMore) {
      return;
    }

    _isLoadingMore = true;

    final result = await _repository.getNotifications(
      limit: 20,
      cursor: currentState.nextCursor,
    );

    result.fold(
      (failure) {
        _isLoadingMore = false;
      },
      (page) {
        _isLoadingMore = false;
        emit(
          currentState.copyWith(
            notifications: [...currentState.notifications, ...page.items],
            nextCursor: page.nextCursor,
            hasReachedMax: page.nextCursor == null || page.nextCursor!.isEmpty,
          ),
        );
      },
    );
  }

  Future<void> markAsRead(String id) async {
    final currentState = state;
    if (currentState is! NotificationsSuccess) return;

    final index = currentState.notifications.indexWhere((n) => n.id == id);
    if (index == -1 || currentState.notifications[index].isRead) return;

    // Optimistic Update
    final updatedNotifications = List<NotificationModel>.from(
      currentState.notifications,
    );
    final notification = updatedNotifications[index];

    updatedNotifications[index] = notification.copyWith(readAt: DateTime.now());

    final newUnreadCount = currentState.unreadCount > 0
        ? currentState.unreadCount - 1
        : 0;

    emit(
      currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ),
    );

    final result = await _repository.readNotification(id);
    result.fold((failure) {
      // Revert on failure
      final revertedNotifications = List<NotificationModel>.from(
        currentState.notifications,
      );
      emit(
        currentState.copyWith(
          notifications: revertedNotifications,
          unreadCount: currentState.unreadCount,
        ),
      );
    }, (_) => null);
  }

  Future<void> markAllAsRead() async {
    final currentState = state;
    if (currentState is! NotificationsSuccess) return;

    final updatedNotifications = currentState.notifications.map((n) {
      if (!n.isRead) {
        return n.copyWith(readAt: DateTime.now());
      }
      return n;
    }).toList();

    emit(
      currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      ),
    );

    final result = await _repository.readAllNotifications();
    result.fold((failure) {
      // Revert on failure
      emit(currentState);
    }, (_) => null);
  }

  Future<void> fetchUnreadCount() async {
    final currentState = state;
    final result = await _repository.getUnreadCount();

    result.fold((failure) => null, (count) {
      if (currentState is NotificationsSuccess) {
        emit(currentState.copyWith(unreadCount: count));
      } else {
        emit(NotificationsSuccess(
          notifications: const [],
          unreadCount: count,
          hasReachedMax: true,
        ));
      }
    });
  }
}
