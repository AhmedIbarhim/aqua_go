class PrivacyPolicySection {
  final String title;
  final String content;

  const PrivacyPolicySection({
    required this.title,
    required this.content,
  });
}

class PrivacyPolicyText {
  final String title;
  final String intro;
  final List<PrivacyPolicySection> sections;
  final String footer;

  const PrivacyPolicyText({
    required this.title,
    required this.intro,
    required this.sections,
    required this.footer,
  });
}
