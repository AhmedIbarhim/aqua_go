import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class ChatRemoteDataSource {
  final APIClient _apiClient;

  ChatRemoteDataSource(this._apiClient);

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

  Future<Either<Failure, dynamic>> presignAttachment({
    required String threadId,
    required Map<String, dynamic> data,
  }) {
    return _apiClient.post(
      Endpoints.chatAttachmentPresign(threadId),
      data: data,
    );
  }

  Future<Either<Failure, dynamic>> markRead(String threadId) {
    return _apiClient.post(Endpoints.readChatThread(threadId));
  }

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
