/// Response of the attachment presign call: a short-lived PUT [url] and the
/// [objectKey] to reference when sending the message.
class PresignedUrl {
  final String url;
  final String objectKey;
  final String? expiresAt;

  const PresignedUrl({
    required this.url,
    required this.objectKey,
    this.expiresAt,
  });

  factory PresignedUrl.fromJson(Map<String, dynamic> json) {
    return PresignedUrl(
      url: json['url'] as String? ?? '',
      objectKey:
          json['objectKey'] as String? ?? json['key'] as String? ?? '',
      expiresAt: json['expiresAt'] as String?,
    );
  }
}
