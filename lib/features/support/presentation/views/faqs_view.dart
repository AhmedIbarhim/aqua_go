import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/custom_loading_indicator.dart';
import '../../../../core/components/error_retry_widget.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../data/models/Faq_model.dart';
import '../controllers/faqs_cubit.dart';
import '../controllers/faqs_state.dart';
import '../widgets/faq_tile.dart';

class FaqsView extends StatefulWidget {
  const FaqsView({super.key});

  @override
  State<FaqsView> createState() => _FaqsViewState();
}

class _FaqsViewState extends State<FaqsView> {
  String? _expandedFaqId;

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.support_faq.tr(context: context),
        centerTitle: false,
      ),
      body: Column(
        children: [
          SizedBox(height: sh(16)),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sw(24)),
                  topRight: Radius.circular(sw(24)),
                ),
              ),
              padding: EdgeInsets.all(sw(24)),
              child: BlocBuilder<FaqsCubit, FaqsState>(
                builder: (context, state) {
                  if (state is FaqsLoading) {
                    return const Center(
                      child: CustomLoadingIndicator(size: 100),
                    );
                  } else if (state is FaqsFailure) {
                    return ErrorRetryWidget(
                      errorMessage: state.message,
                      onRetry: () => context.read<FaqsCubit>().fetchFaqs(),
                    );
                  } else if (state is FaqsSuccess) {
                    final faqs = state.faqs;
                    if (faqs.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // Grouped by the backend's category slug, and headed by the
                    // backend's own localised categoryName. The category SET is
                    // admin-managed, so a closed client enum could not represent
                    // it: anything it did not know fell through to Service and
                    // was silently misfiled, and a renamed category never
                    // reached the app at all.
                    //
                    // LinkedHashMap keeps insertion order, so the sections
                    // follow the order the API returned (displayOrder) instead
                    // of a hardcoded list.
                    final Map<String, List<FaqModel>> groupedFaqs = {};
                    for (final faq in faqs) {
                      groupedFaqs.putIfAbsent(faq.category, () => []).add(faq);
                    }
                    final activeCategories = groupedFaqs.keys.toList();

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: activeCategories.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: sh(24)),
                      itemBuilder: (context, index) {
                        final category = activeCategories[index];
                        final categoryFaqs = groupedFaqs[category]!;
                        final categoryName = categoryFaqs.first.categoryName;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: sh(12)),
                              child: Text(
                                categoryName,
                                style: AppTextStyles.semiBold18.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: categoryFaqs.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: sh(12)),
                              itemBuilder: (context, index) {
                                final faq = categoryFaqs[index];
                                final isExpanded = _expandedFaqId == faq.id;

                                return FaqTile(
                                  faq: faq,
                                  isExpanded: isExpanded,
                                  onTap: () {
                                    setState(() {
                                      _expandedFaqId = isExpanded
                                          ? null
                                          : faq.id;
                                    });
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
