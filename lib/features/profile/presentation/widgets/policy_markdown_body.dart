import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../data/models/policy_model.dart';

/// Renders an admin-authored policy document (`bodyMarkdown` — headings,
/// paragraphs, lists). The document names itself via its own leading heading.
///
/// Unlike `FaqModel.answerBullets`, the body is NOT line-split — a full legal
/// document's structure (nested headings, lists) would flatten to noise.
/// `MarkdownBody.build` never sets a `textDirection` on the `Text`/`RichText`
/// it emits, so it inherits the ambient `Directionality` the same way every
/// other `Text` widget on these screens does; no manual RTL override needed.
class PolicyMarkdownBody extends StatelessWidget {
  const PolicyMarkdownBody({super.key, required this.policy});

  final PolicyModel policy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // No separate title row. The app bar already names the document, and
        // bodyMarkdown opens with its own `## <title>` heading, so rendering
        // policy.title here printed it a third time.
        MarkdownBody(
          data: policy.bodyMarkdown,
          shrinkWrap: true,
          onTapLink: (text, href, title) async {
            if (href == null) return;
            final uri = Uri.tryParse(href);
            if (uri == null) return;
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {}
          },
          styleSheet: MarkdownStyleSheet(
            h1: AppTextStyles.semiBold24.copyWith(color: colors.textPrimary),
            h1Padding: const EdgeInsets.only(top: 16, bottom: 8),
            h2: AppTextStyles.semiBold18.copyWith(color: colors.textPrimary),
            h2Padding: const EdgeInsets.only(top: 16, bottom: 8),
            h3: AppTextStyles.medium16.copyWith(color: colors.textPrimary),
            h3Padding: const EdgeInsets.only(top: 12, bottom: 6),
            p: AppTextStyles.regular16.copyWith(
              color: colors.textSecondary,
              height: 1.6,
            ),
            pPadding: const EdgeInsets.only(bottom: 8),
            strong: AppTextStyles.medium16.copyWith(
              color: colors.textPrimary,
              height: 1.6,
            ),
            em: AppTextStyles.regular16.copyWith(
              color: colors.textSecondary,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
            listBullet: AppTextStyles.regular16.copyWith(
              color: colors.textSecondary,
              height: 1.6,
            ),
            blockquote: AppTextStyles.regular16.copyWith(
              color: colors.textSecondary,
              height: 1.6,
            ),
            blockquoteDecoration: BoxDecoration(
              color: colors.background,
              border: BorderDirectional(
                start: BorderSide(color: colors.borderSecondary, width: 3),
              ),
            ),
            a: AppTextStyles.regular16.copyWith(
              color: colors.primary,
              decoration: TextDecoration.underline,
            ),
            horizontalRuleDecoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colors.borderSecondary.withAlpha(50),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
