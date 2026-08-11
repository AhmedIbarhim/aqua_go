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
    return {'filename': filename, 'mimeType': mimeType, 'sizeBytes': sizeBytes};
  }
}
