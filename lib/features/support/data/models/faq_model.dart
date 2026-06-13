class FaqModel {
  final String id;
  final String category;
  final String locale;
  final String slug;
  final String title;
  final String bodyMarkdown;
  final int displayOrder;
  final int helpfulUp;
  final int helpfulDown;

  const FaqModel({
    required this.id,
    required this.category,
    required this.locale,
    required this.slug,
    required this.title,
    required this.bodyMarkdown,
    required this.displayOrder,
    required this.helpfulUp,
    required this.helpfulDown,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      locale: json['locale'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      bodyMarkdown: json['bodyMarkdown'] as String? ?? '',
      displayOrder: json['displayOrder'] as int? ?? 0,
      helpfulUp: json['helpfulUp'] as int? ?? 0,
      helpfulDown: json['helpfulDown'] as int? ?? 0,
    );
  }

  // Compatibility getter for widget title rendering
  String get question => title;

  // Compatibility getter parsing bodyMarkdown into a list of bullet points
  List<String> get answerBullets {
    if (bodyMarkdown.isEmpty) return [];
    
    // Split by newlines
    final lines = bodyMarkdown.split('\n');
    return lines
        .map((line) {
          var trimmed = line.trim();
          // Strip leading bullet symbols (e.g., '-', '*', or '•')
          if (trimmed.startsWith('-')) {
            trimmed = trimmed.substring(1).trim();
          } else if (trimmed.startsWith('*')) {
            trimmed = trimmed.substring(1).trim();
          } else if (trimmed.startsWith('•')) {
            trimmed = trimmed.substring(1).trim();
          }
          return trimmed;
        })
        .where((line) => line.isNotEmpty)
        .toList();
  }
}
