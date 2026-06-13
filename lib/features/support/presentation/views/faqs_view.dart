import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/custom_loading_indicator.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../controllers/faqs_cubit.dart';
import '../controllers/faqs_state.dart';
import '../widgets/faq_tile.dart';

class FaqsView extends StatefulWidget {
  const FaqsView({super.key});

  @override
  State<FaqsView> createState() => _FaqsViewState();
}

class _FaqsViewState extends State<FaqsView> {
  int? _expandedIndex = 0;

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.support_faq.tr(),
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.message,
                            style: AppTextStyles.medium16.copyWith(
                              color: context.colors.errorLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: sh(16)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(sw(8)),
                              ),
                            ),
                            onPressed: () =>
                                context.read<FaqsCubit>().fetchFaqs(),
                            child: Text(
                              LocaleKeys.retry.tr(),
                              style: AppTextStyles.bold13.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is FaqsSuccess) {
                    final faqs = state.faqs;
                    if (faqs.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: faqs.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: sh(16)),
                      itemBuilder: (context, index) {
                        final faq = faqs[index];
                        final isExpanded = _expandedIndex == index;

                        return FaqTile(
                          faq: faq,
                          isExpanded: isExpanded,
                          onTap: () {
                            setState(() {
                              _expandedIndex = isExpanded ? null : index;
                            });
                          },
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
