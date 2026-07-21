part of 'chat_thread_cubit.dart';

sealed class ChatThreadState extends Equatable {
  const ChatThreadState();

  @override
  List<Object?> get props => [];
}

final class ChatThreadInitial extends ChatThreadState {}

final class ChatThreadLoading extends ChatThreadState {}

final class ChatThreadLoaded extends ChatThreadState {
  final ThreadModel thread;
  final bool isSending;
  final bool isUploading;
  final bool isLoadingOlder;
  final bool hasMoreOlder;

  const ChatThreadLoaded({
    required this.thread,
    this.isSending = false,
    this.isUploading = false,
    this.isLoadingOlder = false,
    this.hasMoreOlder = false,
  });

  ChatThreadLoaded copyWith({
    ThreadModel? thread,
    bool? isSending,
    bool? isUploading,
    bool? isLoadingOlder,
    bool? hasMoreOlder,
  }) {
    return ChatThreadLoaded(
      thread: thread ?? this.thread,
      isSending: isSending ?? this.isSending,
      isUploading: isUploading ?? this.isUploading,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
    );
  }

  @override
  List<Object?> get props => [
    thread,
    isSending,
    isUploading,
    isLoadingOlder,
    hasMoreOlder,
  ];
}

final class ChatThreadError extends ChatThreadState {
  final String message;
  const ChatThreadError(this.message);

  @override
  List<Object?> get props => [message];
}

/// One-shot notice (send/upload/report outcome). Handled by a BlocListener; the
/// Chat BlocBuilder ignores it via buildWhen so the message list is untouched.
/// User-facing text lives in the view (mapped from [code]); [detail] carries an
/// already-localised backend failure message when present.
final class ChatThreadActionNotice extends ChatThreadState {
  final ChatNoticeCode code;
  final String? detail;
  final int tick;

  const ChatThreadActionNotice({
    required this.code,
    this.detail,
    required this.tick,
  });

  bool get isError => code != ChatNoticeCode.reportSucceeded;

  @override
  List<Object?> get props => [code, detail, tick];
}
