class PageResponse<T> {
  final List<T> items;
  final String? nextCursor;
  final int? totalMatching;

  const PageResponse({
    required this.items,
    this.nextCursor,
    this.totalMatching,
  });

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) itemFromJson,
  ) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return PageResponse<T>(
      items: rawItems
          .map((e) => itemFromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
      totalMatching: (json['totalMatching'] as num?)?.toInt(),
    );
  }
}
