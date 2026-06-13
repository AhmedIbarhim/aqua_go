import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../core/route/routes.dart';
import '../controllers/complaints_cubit/complaints_cubit.dart';
import '../controllers/complaints_cubit/complaints_state.dart';
import '../widgets/complaint_record_card.dart';
import 'complaint_details_view.dart';

class ComplaintsRecordView extends StatefulWidget {
  const ComplaintsRecordView({super.key});

  @override
  State<ComplaintsRecordView> createState() => _ComplaintsRecordViewState();
}

class _ComplaintsRecordViewState extends State<ComplaintsRecordView> {
  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.support_complaint_log.tr(),
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
              padding: EdgeInsets.symmetric(
                horizontal: sw(24),
                vertical: sh(24),
              ),
              child: BlocBuilder<ComplaintsCubit, ComplaintsState>(
                builder: (context, state) {
                  if (state is ComplaintsLoading) {
                    return const Center(
                      child: CustomLoadingIndicator(size: 100),
                    );
                  } else if (state is ComplaintsFailure) {
                    return Center(
                      child: Text(
                        state.message,
                        style: AppTextStyles.medium16.copyWith(
                          color: context.colors.errorLight,
                        ),
                      ),
                    );
                  } else if (state is ComplaintsSuccess) {
                    final complaints = state.complaints;
                    if (complaints.isEmpty) {
                      return _buildEmptyState();
                    }
                    return RefreshIndicator(
                      onRefresh: () =>
                          context.read<ComplaintsCubit>().fetchComplaints(),
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: complaints.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: sh(12)),
                        itemBuilder: (context, index) {
                          final complaint = complaints[index];
                          return ComplaintRecordCard(
                            complaint: complaint,
                            onTap: () {
                              context
                                  .pushNamed(
                                    Routes.complaintDetails,
                                    arguments: ComplaintDetailsArgs(
                                      complaintId: complaint.id,
                                      initialComplaint: complaint,
                                    ),
                                  )
                                  .then((_) {
                                    if (context.mounted) {
                                      context
                                          .read<ComplaintsCubit>()
                                          .fetchComplaints();
                                    }
                                  });
                            },
                          );
                        },
                      ),
                    );
                  }
                  return _buildEmptyState();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.emptyComplaints,
            width: 100,
            height: 100,
            colorFilter: ColorFilter.mode(
              context.colors.textSecondary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            LocaleKeys.complaint_no_complaints.tr(),
            style: AppTextStyles.medium16.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
