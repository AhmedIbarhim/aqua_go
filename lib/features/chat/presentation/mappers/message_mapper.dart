import 'package:flutter_chat_core/flutter_chat_core.dart';

import '../../data/enums/chat_sender_role_enum.dart';
import '../../data/models/message_model.dart';

class MessageMapper {
  static const String supportAuthorId = 'aqua_support_agent';
  static const String workerAuthorId = 'aqua_worker';
  static const String systemAuthorId = 'aqua_system';

  static String authorIdFor(ChatSenderRole role, String currentUserId) {
    switch (role) {
      case ChatSenderRole.customer:
        return currentUserId;
      case ChatSenderRole.supportAgent:
        return supportAuthorId;
      case ChatSenderRole.worker:
        return workerAuthorId;
      case ChatSenderRole.system:
        return systemAuthorId;
    }
  }

  static DateTime _parseCreatedAt(String raw) {
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }

  static Message toChatMessage(MessageModel model, String currentUserId) {
    final authorId = authorIdFor(model.senderRole, currentUserId);
    final createdAt = _parseCreatedAt(model.createdAt);
    final status = model.readAt != null
        ? MessageStatus.seen
        : MessageStatus.delivered;

    if (model.senderRole.isSystem) {
      return Message.system(
        id: model.id,
        authorId: authorId,
        createdAt: createdAt,
        text: model.body,
      );
    }

    if (model.hasAttachment) {
      if (model.isImageAttachment) {
        return Message.image(
          id: model.id,
          authorId: authorId,
          createdAt: createdAt,
          status: status,
          source: model.attachmentDownloadUrl!,
          text: model.body.trim().isEmpty ? null : model.body,
          size: model.attachmentSizeBytes,
        );
      }
      return Message.file(
        id: model.id,
        authorId: authorId,
        createdAt: createdAt,
        status: status,
        source: model.attachmentDownloadUrl!,
        name: model.body.trim().isEmpty ? 'attachment' : model.body,
        size: model.attachmentSizeBytes,
        mimeType: model.attachmentMimeType,
      );
    }

    return Message.text(
      id: model.id,
      authorId: authorId,
      createdAt: createdAt,
      status: status,
      text: model.body,
    );
  }
}
