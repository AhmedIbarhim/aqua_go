import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';

import '../../../../../core/helpers/idempotency_key_helper.dart';
import '../../../data/enums/chat_category_enum.dart';
import '../../../data/enums/chat_thread_kind_enum.dart';
import '../../../data/enums/chat_thread_status_enum.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/send_message_request.dart';
import '../../../data/models/thread_model.dart';
import '../../../data/repos/chat_repository.dart';
import '../../mappers/message_mapper.dart';

part 'chat_thread_state.dart';

/// Semantic outcome of a one-shot action; the view maps it to localised text.
enum ChatNoticeCode {
  sendFailed,
  uploadFailed,
  reportSucceeded,
  reportFailed,
}

/// A retained outgoing send: the request body + the idempotency key minted for
/// its first attempt. Reused verbatim on retry so the backend dedups.
class _PendingSend {
  final SendMessageRequest request;
  final String idempotencyKey;

  const _PendingSend({required this.request, required this.idempotencyKey});
}

/// Drives a single open thread: loads the message history into an
/// [InMemoryChatController], marks the thread read, polls for new replies every
/// ~5s, sends messages optimistically (insert → reconcile), loads older pages,
/// reports messages, and handles the attachment (presign → PUT → send) flow.
///
/// The Chat widget listens to [chatController] directly, so message-list changes
/// do not flow through cubit state — cubit state only carries thread meta +
/// transient flags (sending / uploading / loading-older) and one-shot notices.
class ChatThreadCubit extends Cubit<ChatThreadState> {
  final ChatRepository _repository;
  final String threadId;
  final String _currentUserId;

  final InMemoryChatController chatController = InMemoryChatController();

  ThreadModel? _thread;

  /// Server message ids currently in the controller (excludes optimistic temps).
  final Set<String> _knownIds = {};

  /// Cursor to the NEXT OLDER page (from the newest-first messages endpoint).
  String? _olderCursor;
  bool _hasMoreOlder = false;
  bool _isLoadingOlder = false;

  Timer? _pollTimer;
  bool _isPolling = false;
  bool _disposed = false;
  int _noticeTick = 0;
  int _tempCounter = 0;

  /// Retained outgoing sends keyed by their optimistic temp id, so a failed send
  /// can be retried with the SAME idempotency key (backend dedups → a resend
  /// never duplicates the row). Entries are dropped once the server confirms.
  final Map<String, _PendingSend> _pendingSends = {};

  static const int _pageSize = 20;
  static const Duration _pollInterval = Duration(seconds: 5);

  ChatThreadCubit({
    required ChatRepository repository,
    required this.threadId,
    required String currentUserId,
    ThreadModel? initialThread,
  }) : _repository = repository,
       _currentUserId = currentUserId,
       _thread = initialThread,
       super(ChatThreadInitial());

  ThreadModel get _resolvedThread =>
      _thread ??
      ThreadModel(
        id: threadId,
        kind: ChatThreadKind.customerSupport,
        status: ChatThreadStatus.open,
        category: ChatCategory.general,
      );

  // ---------------------------------------------------------------------------
  // Load + polling
  // ---------------------------------------------------------------------------

  Future<void> open() async {
    emit(ChatThreadLoading());

    // Resolve thread meta (status/subject) when deep-linked without it.
    if (_thread == null) {
      await _resolveThreadMeta();
    }

    final result = await _repository.getMessages(
      threadId: threadId,
      limit: _pageSize,
    );

    if (_disposed) return;

    await result.fold((failure) async {
      emit(ChatThreadError(failure.message));
    }, (page) async {
      // API is newest-first; the controller wants oldest-first (index 0 = oldest).
      final chronological = page.items.reversed.toList();
      final mapped = chronological
          .map((m) => MessageMapper.toChatMessage(m, _currentUserId))
          .toList();
      _knownIds
        ..clear()
        ..addAll(chronological.map((m) => m.id));
      await chatController.setMessages(mapped);
      _olderCursor = page.nextCursor;
      _hasMoreOlder = page.hasMore;

      _markReadSilently();
      _emitLoaded();
      _startPolling();
    });
  }

  /// Best-effort thread-meta resolution for a deep-linked thread: scans the
  /// first page of the inbox for the id. Falls back to an OPEN placeholder.
  Future<void> _resolveThreadMeta() async {
    final result = await _repository.getThreads(limit: _pageSize);
    result.fold((_) {}, (page) {
      for (final t in page.items) {
        if (t.id == threadId) {
          _thread = t;
          break;
        }
      }
    });
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  Future<void> _poll() async {
    if (_disposed || _isPolling) return;
    _isPolling = true;
    final result = await _repository.getMessages(
      threadId: threadId,
      limit: _pageSize,
    );
    _isPolling = false;
    if (_disposed) return;
    result.fold((_) {}, (page) => _reconcile(page.items));
  }

  /// Manual refresh: re-poll newest immediately. No caller today — the app-bar
  /// action was removed once the background poll made it redundant — kept as
  /// the entry point for a pull-to-refresh gesture, the only place a manual
  /// refresh still makes sense on this screen.
  Future<void> refresh() => _poll();

  /// Merges a freshly fetched newest-first page into the controller: appends
  /// unseen messages in chronological order and updates changed ones (e.g. a
  /// sent message becoming "seen").
  Future<void> _reconcile(List<MessageModel> newestFirst) async {
    final chronological = newestFirst.reversed.toList();
    bool inboundArrived = false;
    for (final model in chronological) {
      final mapped = MessageMapper.toChatMessage(model, _currentUserId);
      if (_knownIds.contains(model.id)) {
        // Update in place if something changed (status/read/content).
        final existing = _findById(model.id);
        if (existing != null && existing != mapped) {
          await chatController.updateMessage(existing, mapped);
        }
        continue;
      }
      await chatController.insertMessage(mapped);
      _knownIds.add(model.id);
      if (!model.senderRole.isMe) inboundArrived = true;
    }
    if (inboundArrived) {
      _markReadSilently();
      final t = _resolvedThread;
      if (t.unreadCount != 0) {
        _thread = t.copyWith(unreadCount: 0);
        _emitLoaded();
      }
    }
  }

  Future<void> loadOlder() async {
    if (_disposed || _isLoadingOlder || !_hasMoreOlder) return;
    _isLoadingOlder = true;
    _emitLoaded();
    final result = await _repository.getMessages(
      threadId: threadId,
      cursor: _olderCursor,
      limit: _pageSize,
    );
    _isLoadingOlder = false;
    if (_disposed) return;
    result.fold((_) => _emitLoaded(), (page) async {
      // Older page is also newest-first; prepend oldest-first at index 0.
      final chronological = page.items.reversed
          .where((m) => !_knownIds.contains(m.id))
          .toList();
      if (chronological.isNotEmpty) {
        final mapped = chronological
            .map((m) => MessageMapper.toChatMessage(m, _currentUserId))
            .toList();
        await chatController.insertAllMessages(mapped, index: 0);
        _knownIds.addAll(chronological.map((m) => m.id));
      }
      _olderCursor = page.nextCursor;
      _hasMoreOlder = page.hasMore;
      _emitLoaded();
    });
  }

  // ---------------------------------------------------------------------------
  // Send
  // ---------------------------------------------------------------------------

  Future<void> sendText(String text) async {
    final body = text.trim();
    if (body.isEmpty) return;

    final tempId = _nextTempId();
    final idempotencyKey = IdempotencyKeyHelper.generate(
      prefix: 'chat-message-send',
      userId: _currentUserId,
      requestId: threadId,
      index: tempId,
    );

    // Retain the request + idempotency key so a failed send can be retried with
    // the SAME key (see [resendMessage] / [_dispatchSend]).
    _pendingSends[tempId] = _PendingSend(
      request: SendMessageRequest(body: body),
      idempotencyKey: idempotencyKey,
    );

    final optimistic = Message.text(
      id: tempId,
      authorId: _currentUserId,
      createdAt: DateTime.now(),
      text: body,
      metadata: const {'sending': true},
    );
    await chatController.insertMessage(optimistic);

    await _dispatchSend(tempId);
  }

  /// Re-sends a message that previously failed (tap-to-resend on a failed
  /// bubble). Flips the failed bubble back to "sending" IN PLACE (keeps its list
  /// position) and re-runs the exact same send with the ORIGINAL idempotency
  /// key, so the backend dedups and no duplicate row is created. No-op for
  /// anything that is not a retryable failed text message (attachment sends have
  /// no optimistic bubble, so nothing to retry there).
  Future<void> resendMessage(Message failedMessage) async {
    final tempId = failedMessage.id;
    if (!_pendingSends.containsKey(tempId)) return;

    final current = _findById(tempId);
    if (current is! TextMessage) return;

    final resending = current.copyWith(
      metadata: const {'sending': true},
      status: MessageStatus.sending,
    );
    await chatController.updateMessage(current, resending);

    await _dispatchSend(tempId);
  }

  /// Shared POST path for the initial send and every retry. Reuses the request +
  /// idempotency key retained under [tempId]: on success reconciles the
  /// optimistic bubble to the server message; on failure flips it back to
  /// failed and surfaces a notice.
  Future<void> _dispatchSend(String tempId) async {
    final pending = _pendingSends[tempId];
    if (pending == null) return;
    _emitLoaded(isSending: true);

    final result = await _repository.sendMessage(
      threadId: threadId,
      request: pending.request,
      idempotencyKey: pending.idempotencyKey,
    );
    if (_disposed) return;

    await result.fold((failure) async {
      await _markOptimisticFailed(tempId);
      _emitLoaded(isSending: false);
      _emitNotice(ChatNoticeCode.sendFailed, detail: failure.message);
    }, (serverMessage) async {
      _pendingSends.remove(tempId);
      await _settleOptimistic(tempId, serverMessage);
      _reopenIfNeeded();
      _emitLoaded(isSending: false);
    });
  }

  /// Attachment flow: presign + PUT (via repo), then send-message referencing
  /// the object key. No optimistic bubble — an [isUploading] flag drives the UI
  /// and the server-returned message (with its download URL) is inserted on
  /// success.
  Future<void> sendAttachment(File file) async {
    _emitLoaded(isUploading: true);

    final uploadResult = await _repository.uploadAttachment(
      threadId: threadId,
      file: file,
    );
    if (_disposed) return;

    await uploadResult.fold((failure) async {
      _emitLoaded(isUploading: false);
      _emitNotice(ChatNoticeCode.uploadFailed, detail: failure.message);
    }, (upload) async {
      final tempId = _nextTempId();
      final idempotencyKey = IdempotencyKeyHelper.generate(
        prefix: 'chat-message-send',
        userId: _currentUserId,
        requestId: threadId,
        index: tempId,
      );
      final result = await _repository.sendMessage(
        threadId: threadId,
        request: SendMessageRequest(
          body: '',
          attachmentObjectKey: upload.objectKey,
          attachmentSizeBytes: upload.sizeBytes,
          attachmentMimeType: upload.mimeType,
        ),
        idempotencyKey: idempotencyKey,
      );
      if (_disposed) return;
      await result.fold((failure) async {
        _emitLoaded(isUploading: false);
        _emitNotice(ChatNoticeCode.uploadFailed, detail: failure.message);
      }, (serverMessage) async {
        if (!_knownIds.contains(serverMessage.id)) {
          await chatController.insertMessage(
            MessageMapper.toChatMessage(serverMessage, _currentUserId),
          );
          _knownIds.add(serverMessage.id);
        }
        _reopenIfNeeded();
        _emitLoaded(isUploading: false);
      });
    });
  }

  Future<void> reportMessage(String messageId) async {
    final result = await _repository.reportMessage(messageId);
    if (_disposed) return;
    result.fold(
      (failure) =>
          _emitNotice(ChatNoticeCode.reportFailed, detail: failure.message),
      (_) => _emitNotice(ChatNoticeCode.reportSucceeded),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _nextTempId() => 'temp_${DateTime.now().microsecondsSinceEpoch}_${_tempCounter++}';

  /// Resolves an optimistic message once the server confirms it. Guards the poll
  /// race: if a poll already inserted the real id, just drop the temp bubble.
  Future<void> _settleOptimistic(String tempId, MessageModel serverMessage) async {
    final temp = _findById(tempId);
    if (temp == null) {
      _knownIds.add(serverMessage.id);
      return;
    }
    if (_knownIds.contains(serverMessage.id)) {
      await chatController.removeMessage(temp);
      return;
    }
    await chatController.updateMessage(
      temp,
      MessageMapper.toChatMessage(serverMessage, _currentUserId),
    );
    _knownIds.add(serverMessage.id);
  }

  Future<void> _markOptimisticFailed(String tempId) async {
    final temp = _findById(tempId);
    if (temp == null) return;
    final failed = (temp as TextMessage).copyWith(
      metadata: const {'sending': false},
      failedAt: DateTime.now(),
      status: MessageStatus.error,
    );
    await chatController.updateMessage(temp, failed);
  }

  Message? _findById(String id) {
    for (final m in chatController.messages) {
      if (m.id == id) return m;
    }
    return null;
  }

  void _reopenIfNeeded() {
    final t = _resolvedThread;
    if (t.status.isReopenable) {
      _thread = t.copyWith(status: ChatThreadStatus.open);
    }
  }

  void _markReadSilently() {
    _repository.markRead(threadId);
  }

  void _emitLoaded({bool? isSending, bool? isUploading}) {
    final current = state;
    final base = current is ChatThreadLoaded
        ? current
        : ChatThreadLoaded(thread: _resolvedThread);
    emit(
      base.copyWith(
        thread: _resolvedThread,
        isSending: isSending,
        isUploading: isUploading,
        isLoadingOlder: _isLoadingOlder,
        hasMoreOlder: _hasMoreOlder,
      ),
    );
  }

  void _emitNotice(ChatNoticeCode code, {String? detail}) {
    emit(
      ChatThreadActionNotice(code: code, detail: detail, tick: _noticeTick++),
    );
    // Restore the structural state so subsequent reads see a Loaded state.
    _emitLoaded();
  }

  @override
  Future<void> close() {
    _disposed = true;
    _pollTimer?.cancel();
    chatController.dispose();
    return super.close();
  }
}
