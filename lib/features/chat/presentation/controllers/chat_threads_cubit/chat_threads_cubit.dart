import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/enums/chat_category_enum.dart';
import '../../../data/enums/chat_thread_kind_enum.dart';
import '../../../data/models/create_thread_request.dart';
import '../../../data/models/thread_model.dart';
import '../../../data/repos/chat_repository.dart';

part 'chat_threads_state.dart';

/// Drives the support inbox: cursor-paginated thread list, pull-to-refresh, and
/// new-ticket creation.
class ChatThreadsCubit extends Cubit<ChatThreadsState> {
  final ChatRepository _repository;

  ChatThreadsCubit(this._repository) : super(ChatThreadsInitial());

  final List<ThreadModel> _threads = [];
  String? _nextCursor;
  bool _hasMore = false;
  bool _isFetching = false;

  static const int _pageSize = 20;

  Future<void> loadThreads() async {
    if (_isFetching) return;
    _isFetching = true;
    emit(ChatThreadsLoading());
    final result = await _repository.getThreads(limit: _pageSize);
    _isFetching = false;
    result.fold((failure) => emit(ChatThreadsError(failure.message)), (page) {
      _threads
        ..clear()
        ..addAll(page.items);
      _nextCursor = page.nextCursor;
      _hasMore = page.hasMore;
      _emitLoaded();
    });
  }

  /// Pull-to-refresh — reloads the first page without flashing the full-screen
  /// loader (the RefreshIndicator shows its own spinner).
  Future<void> refresh() async {
    if (_isFetching) return;
    _isFetching = true;
    final result = await _repository.getThreads(limit: _pageSize);
    _isFetching = false;
    result.fold((failure) {
      // Keep the current list on a refresh failure; only surface an error
      // screen when we have nothing to show.
      if (_threads.isEmpty) {
        emit(ChatThreadsError(failure.message));
      } else {
        _emitLoaded();
      }
    }, (page) {
      _threads
        ..clear()
        ..addAll(page.items);
      _nextCursor = page.nextCursor;
      _hasMore = page.hasMore;
      _emitLoaded();
    });
  }

  Future<void> loadMore() async {
    if (_isFetching || !_hasMore) return;
    _isFetching = true;
    emit(ChatThreadsLoaded(threads: List.of(_threads), hasMore: _hasMore, isLoadingMore: true));
    final result = await _repository.getThreads(
      cursor: _nextCursor,
      limit: _pageSize,
    );
    _isFetching = false;
    result.fold((_) => _emitLoaded(), (page) {
      _threads.addAll(page.items);
      _nextCursor = page.nextCursor;
      _hasMore = page.hasMore;
      _emitLoaded();
    });
  }

  Future<void> createTicket({
    required ChatCategory category,
    required String subject,
  }) async {
    emit(ChatThreadCreating());
    final result = await _repository.createThread(
      CreateThreadRequest(
        kind: ChatThreadKind.customerSupport,
        category: category,
        subject: subject.trim(),
      ),
    );
    result.fold((failure) {
      emit(ChatThreadCreateError(failure.message));
      _emitLoaded();
    }, (thread) {
      // Surface the new thread at the top of the local list optimistically.
      _threads.insert(0, thread);
      emit(ChatThreadCreated(thread));
      _emitLoaded();
    });
  }

  void _emitLoaded() {
    emit(
      ChatThreadsLoaded(
        threads: List.of(_threads),
        hasMore: _hasMore,
        isLoadingMore: false,
      ),
    );
  }
}
