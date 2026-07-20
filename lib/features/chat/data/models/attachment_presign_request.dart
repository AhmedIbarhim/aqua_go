/// Body for `POST /chat/threads/{id}/messages/attachment/presign`.
/// The server validates the mime allowlist + 10MB cap and returns a
/// [PresignedUrl] the client PUTs the raw bytes to.
class AttachmentPresignRequest {
  final String filename;
  final String mimeType;
  final int sizeBytes;

  const AttachmentPresignRequest({
    required this.filename,
    required this.mimeType,
    required this.sizeBytes,
  });

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
    };
  }
}
