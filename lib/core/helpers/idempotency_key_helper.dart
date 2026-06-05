class IdempotencyKeyHelper {
  static String generate({
    String? prefix,
    String? userId,
    String? requestId,
    String? index,
  }) {
    final nowToSeconds = DateTime.now().toIso8601String().substring(0, 19);

    final List<String> parts = [];

    if (prefix != null && prefix.isNotEmpty) {
      parts.add(prefix);
    }
    if (userId != null && userId.isNotEmpty) {
      parts.add(userId);
    }
    if (requestId != null && requestId.isNotEmpty) {
      parts.add(requestId);
    }
    if (index != null && index.isNotEmpty) {
      parts.add(index);
    }

    parts.add(nowToSeconds);

    return parts.join(':');
  }
}
