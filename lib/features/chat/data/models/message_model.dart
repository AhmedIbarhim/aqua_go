import '../enums/chat_sender_role_enum.dart';

/// A single chat message. Mirrors the backend `MessageView`.
///
/// Note: `createdAt` / `readAt` are ISO-8601 Instant STRINGS on the wire — they
/// are parsed to [DateTime] only when mapping to the flutter_chat_ui `Message`
/// (see [MessageMapper]); never round-trip this through `Message.fromJson`
/// (that expects epoch-millis via @EpochDateTimeConverter).
class MessageModel {
  final String id;
  final String threadId;
  final String? senderId;
  final ChatSenderRole senderRole;
  final String body;
  final String? attachmentDownloadUrl;
  final int? attachmentSizeBytes;
  final String? attachmentMimeType;
  final bool flaggedForReview;
  final String createdAt;
  final String? readAt;

  const MessageModel({
    required this.id,
    required this.threadId,
    this.senderId,
    required this.senderRole,
    required this.body,
    this.attachmentDownloadUrl,
    this.attachmentSizeBytes,
    this.attachmentMimeType,
    this.flaggedForReview = false,
    required this.createdAt,
    this.readAt,
  });

  bool get hasAttachment =>
      attachmentDownloadUrl != null && attachmentDownloadUrl!.isNotEmpty;

  bool get isImageAttachment =>
      hasAttachment && (attachmentMimeType?.startsWith('image/') ?? false);

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      threadId: json['threadId'] as String? ?? '',
      senderId: json['senderId'] as String?,
      senderRole: ChatSenderRole.fromString(json['senderRole'] as String?),
      body: json['body'] as String? ?? '',
      attachmentDownloadUrl: json['attachmentDownloadUrl'] as String?,
      attachmentSizeBytes: (json['attachmentSizeBytes'] as num?)?.toInt(),
      attachmentMimeType: json['attachmentMimeType'] as String?,
      flaggedForReview: json['flaggedForReview'] as bool? ?? false,
      createdAt:
          json['createdAt'] as String? ??
          DateTime.now().toUtc().toIso8601String(),
      readAt: json['readAt'] as String?,
    );
  }
}
