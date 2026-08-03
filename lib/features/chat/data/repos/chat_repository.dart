import 'dart:io';

import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/helpers/fetch_user_data_helper.dart';
import 'package:aqua_go/core/helpers/idempotency_key_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../data_sources/chat_remote_data_source.dart';
import '../models/attachment_presign_request.dart';
import '../models/create_thread_request.dart';
import '../models/message_model.dart';
import '../models/page_response.dart';
import '../models/presigned_url.dart';
import '../models/send_message_request.dart';
import '../models/thread_model.dart';

/// Result of a successful attachment upload — the object key the send-message
/// call references, plus the metadata the server needs to persist it.
class AttachmentUploadResult {
  final String objectKey;
  final int sizeBytes;
  final String mimeType;

  const AttachmentUploadResult({
    required this.objectKey,
    required this.sizeBytes,
    required this.mimeType,
  });
}

class ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepository(this._remoteDataSource);

  Future<Either<Failure, PageResponse<ThreadModel>>> getThreads({
    String? cursor,
    int limit = 20,
  }) async {
    final result = await _remoteDataSource.getThreads(
      cursor: cursor,
      limit: limit,
    );
    return result.fold((failure) => Left(failure), (data) {
      try {
        final page = PageResponse<ThreadModel>.fromJson(
          data as Map<String, dynamic>,
          ThreadModel.fromJson,
        );
        return Right(page);
      } catch (e) {
        return Left(ServerFailure('Parsing error: $e'));
      }
    });
  }

  Future<Either<Failure, ThreadModel>> createThread(
    CreateThreadRequest request,
  ) async {
    final userId = FetchUserData.getUserId() ?? '';
    final idempotencyKey = IdempotencyKeyHelper.generate(
      prefix: 'chat-thread-create',
      userId: userId,
      requestId: request.category.originalValue,
    );
    final result = await _remoteDataSource.createThread(
      data: request.toJson(),
      idempotencyKey: idempotencyKey,
    );
    return result.fold((failure) => Left(failure), (data) {
      if (data == null) {
        return const Left(ServerFailure('Failed to create ticket'));
      }
      try {
        return Right(ThreadModel.fromJson(data as Map<String, dynamic>));
      } catch (e) {
        return Left(ServerFailure('Parsing error: $e'));
      }
    });
  }

  Future<Either<Failure, PageResponse<MessageModel>>> getMessages({
    required String threadId,
    String? cursor,
    int limit = 20,
  }) async {
    final result = await _remoteDataSource.getMessages(
      threadId: threadId,
      cursor: cursor,
      limit: limit,
    );
    return result.fold((failure) => Left(failure), (data) {
      try {
        final page = PageResponse<MessageModel>.fromJson(
          data as Map<String, dynamic>,
          MessageModel.fromJson,
        );
        return Right(page);
      } catch (e) {
        return Left(ServerFailure('Parsing error: $e'));
      }
    });
  }

  /// Sends a message. The [idempotencyKey] is generated once by the caller (tied
  /// to the optimistic message) and reused across retries so a resend never
  /// duplicates the row.
  Future<Either<Failure, MessageModel>> sendMessage({
    required String threadId,
    required SendMessageRequest request,
    required String idempotencyKey,
  }) async {
    final result = await _remoteDataSource.sendMessage(
      threadId: threadId,
      data: request.toJson(),
      idempotencyKey: idempotencyKey,
    );
    return result.fold((failure) => Left(failure), (data) {
      if (data == null) {
        return const Left(ServerFailure('Failed to send message'));
      }
      try {
        return Right(MessageModel.fromJson(data as Map<String, dynamic>));
      } catch (e) {
        return Left(ServerFailure('Parsing error: $e'));
      }
    });
  }

  Future<Either<Failure, Unit>> markRead(String threadId) async {
    final result = await _remoteDataSource.markRead(threadId);
    return result.fold((failure) => Left(failure), (_) => const Right(unit));
  }

  Future<Either<Failure, Unit>> reportMessage(String messageId) async {
    final userId = FetchUserData.getUserId() ?? '';
    final idempotencyKey = IdempotencyKeyHelper.generate(
      prefix: 'chat-report',
      userId: userId,
      requestId: messageId,
    );
    final result = await _remoteDataSource.reportMessage(
      messageId: messageId,
      idempotencyKey: idempotencyKey,
    );
    return result.fold((failure) => Left(failure), (_) => const Right(unit));
  }

  /// Presigns + PUTs [file] to object storage, returning the object key +
  /// metadata for the follow-up send-message call. Mirrors the COMPLAINT
  /// presign pattern (presign → direct PUT with a fresh Dio → return key).
  Future<Either<Failure, AttachmentUploadResult>> uploadAttachment({
    required String threadId,
    required File file,
  }) async {
    try {
      if (!await file.exists()) {
        return const Left(ServerFailure('File not found'));
      }
      final sizeBytes = await file.length();
      final filename = file.path.split('/').last;
      final extension = filename.contains('.')
          ? filename.split('.').last.toLowerCase()
          : '';
      final mimeType = _mimeForExtension(extension);

      final presignResult = await _remoteDataSource.presignAttachment(
        threadId: threadId,
        data: AttachmentPresignRequest(
          filename: filename,
          mimeType: mimeType,
          sizeBytes: sizeBytes,
        ).toJson(),
      );

      return presignResult.fold((failure) => Left(failure), (data) async {
        if (data == null) {
          return const Left(ServerFailure('Failed to presign attachment'));
        }
        try {
          final presigned = PresignedUrl.fromJson(data as Map<String, dynamic>);
          if (presigned.url.isEmpty || presigned.objectKey.isEmpty) {
            return const Left(ServerFailure('Invalid presign response'));
          }
          final bytes = await file.readAsBytes();
          final uploadDio = Dio();
          final uploadResponse = await uploadDio.put(
            presigned.url,
            data: Stream.fromIterable([bytes]),
            options: Options(
              headers: {
                Headers.contentTypeHeader: mimeType,
                Headers.contentLengthHeader: sizeBytes,
              },
            ),
          );
          final ok =
              uploadResponse.statusCode == 200 ||
              uploadResponse.statusCode == 201 ||
              uploadResponse.statusCode == 204;
          if (!ok) {
            return const Left(ServerFailure('Failed to upload attachment'));
          }
          return Right(
            AttachmentUploadResult(
              objectKey: presigned.objectKey,
              sizeBytes: sizeBytes,
              mimeType: mimeType,
            ),
          );
        } catch (e) {
          return Left(ServerFailure('Upload error: $e'));
        }
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _mimeForExtension(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
