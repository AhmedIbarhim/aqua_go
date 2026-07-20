part of 'chat_threads_cubit.dart';

sealed class ChatThreadsState extends Equatable {
  const ChatThreadsState();

  @override
  List<Object?> get props => [];
}

final class ChatThreadsInitial extends ChatThreadsState {}

final class ChatThreadsLoading extends ChatThreadsState {}

final class ChatThreadsLoaded extends ChatThreadsState {
  final List<ThreadModel> threads;
  final bool hasMore;
  final bool isLoadingMore;

  const ChatThreadsLoaded({
    required this.threads,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [threads, hasMore, isLoadingMore];
}

final class ChatThreadsError extends ChatThreadsState {
  final String message;
  const ChatThreadsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Transient states for the "new ticket" flow. Handled by a BlocListener; the
/// list BlocBuilder ignores them (buildWhen) so the inbox stays rendered.
final class ChatThreadCreating extends ChatThreadsState {}

final class ChatThreadCreated extends ChatThreadsState {
  final ThreadModel thread;
  const ChatThreadCreated(this.thread);

  @override
  List<Object?> get props => [thread];
}

final class ChatThreadCreateError extends ChatThreadsState {
  final String message;
  const ChatThreadCreateError(this.message);

  @override
  List<Object?> get props => [message];
}
