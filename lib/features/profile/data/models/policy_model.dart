import '../../../../core/utils/saudi_wire_format.dart';

/// The `type` path segment `GET /api/customer/policies/{type}` accepts.
/// MARKETING is a valid backend type but has no customer-mobile screen.
abstract final class PolicyType {
  static const String privacy = 'PRIVACY';
  static const String tos = 'TOS';
}

/// Admin-authored, versioned policy document — `PolicyResponse` on the
/// backend. Rendered as Markdown on the Privacy Policy / Terms screens so an
/// operator edit in Content Management reaches customers without an app
/// release.
class PolicyModel {
  final String type;
  final String version;
  final String locale;
  final String title;
  final String bodyMarkdown;
  final DateTime? effectiveAt;

  const PolicyModel({
    required this.type,
    required this.version,
    required this.locale,
    required this.title,
    required this.bodyMarkdown,
    required this.effectiveAt,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      type: json['type'] as String? ?? '',
      version: json['version'] as String? ?? '',
      locale: json['locale'] as String? ?? '',
      title: json['title'] as String? ?? '',
      bodyMarkdown: json['bodyMarkdown'] as String? ?? '',
      // Bare Asia/Riyadh local ISO-8601 — see saudi_wire_format.dart.
      effectiveAt: tryParseWireDateTime(json['effectiveAt'] as String?),
    );
  }
}
