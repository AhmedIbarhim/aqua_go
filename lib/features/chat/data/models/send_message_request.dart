/// Body for `POST /chat/threads/{id}/messages`. A message carries either text,
/// an attachment (via a pre-uploaded object key), or both.
class SendMessageRequest {
  final String body;
  final String? attachmentObjectKey;
  final int? attachmentSizeBytes;
  final String? attachmentMimeType;

  const SendMessageRequest({
    required this.body,
    this.attachmentObjectKey,
    this.attachmentSizeBytes,
    this.attachmentMimeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      if (attachmentObjectKey != null && attachmentObjectKey!.isNotEmpty)
        'attachmentObjectKey': attachmentObjectKey,
      if (attachmentSizeBytes != null)
        'attachmentSizeBytes': attachmentSizeBytes,
      if (attachmentMimeType != null && attachmentMimeType!.isNotEmpty)
        'attachmentMimeType': attachmentMimeType,
    };
  }
}
