import 'package:flutter/material.dart';

import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../local_texts/terms_texts_ar.dart';
import '../local_texts/terms_texts_en.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    final texts = context.isAr ? termsTextsAr : termsTextsEn;

    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(title: texts.appBarTitle, centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      texts.title,
                      style: AppTextStyles.bold18.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      texts.contentP1,
                      style: AppTextStyles.regular16.copyWith(
                        color: context.colors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      texts.contentP2,
                      style: AppTextStyles.regular16.copyWith(
                        color: context.colors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          textAlign: TextAlign.center,
                          texts.footer,
                          style: AppTextStyles.medium16.copyWith(
                            color: context.colors.primary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
