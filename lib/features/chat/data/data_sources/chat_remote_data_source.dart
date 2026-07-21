import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

/// Thin wrapper over [APIClient] for the 7 customer chat operations. All calls
/// return `Either<Failure, dynamic>`; parsing into models happens in the repo.
class ChatRemoteDataSource {
  final APIClient _apiClient;

  ChatRemoteDataSource(this._apiClient);

  /// GET /chat/threads?cursor=&limit= — `PageResponse<ThreadView>`, updatedAt DESC.
  Future<Either<Failure, dynamic>> getThreads({
    String? cursor,
    int limit = 20,
  }) {
    return _apiClient.get(
      Endpoints.chatThreads,
      queryParameters: {
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
    );
  }

  /// POST /chat/threads — create a ticket. Idempotency-Key required.
  Future<Either<Failure, dynamic>> createThread({
    required Map<String, dynamic> data,
    required String idempotencyKey,
  }) {
    return _apiClient.post(
      Endpoints.chatThreads,
      data: data,
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
  }

  /// GET /chat/threads/{id}/messages?cursor=&limit= — `PageResponse<MessageView>`,
  /// createdAt DESC (newest-first). Pass a cursor to page into OLDER messages.
  Future<Either<Failure, dynamic>> getMessages({
    required String threadId,
    String? cursor,
    int limit = 20,
  }) {
    return _apiClient.get(
      Endpoints.chatMessages(threadId),
      queryParameters: {
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
    );
  }

  /// POST /chat/threads/{id}/messages — send a message. Idempotency-Key required.
  Future<Either<Failure, dynamic>> sendMessage({
    required String threadId,
    required Map<String, dynamic> data,
    required String idempotencyKey,
  }) {
    return _apiClient.post(
      Endpoints.chatMessages(threadId),
      data: data,
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
  }

  /// POST /chat/threads/{id}/messages/attachment/presign — not idempotency-gated.
  Future<Either<Failure, dynamic>> presignAttachment({
    required String threadId,
    required Map<String, dynamic> data,
  }) {
    return _apiClient.post(
      Endpoints.chatAttachmentPresign(threadId),
      data: data,
    );
  }

  /// POST /chat/threads/{id}/read — 204.
  Future<Either<Failure, dynamic>> markRead(String threadId) {
    return _apiClient.post(Endpoints.readChatThread(threadId));
  }

  /// POST /chat/messages/{id}/report — 204. Idempotency-Key required.
  Future<Either<Failure, dynamic>> reportMessage({
    required String messageId,
    required String idempotencyKey,
  }) {
    return _apiClient.post(
      Endpoints.reportChatMessage(messageId),
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
  }
}
