import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../controllers/complaint_details_cubit/complaint_details_cubit.dart';
import '../../controllers/complaint_details_cubit/complaint_details_state.dart';
import '../../data/models/complaint_model.dart';
import '../widgets/complaint_booking_details_card.dart';
import '../widgets/complaint_details_description_card.dart';
import '../widgets/complaint_details_photos_card.dart';
import '../widgets/complaint_details_type_card.dart';

class ComplaintDetailsArgs {
  final String complaintId;
  final ComplaintModel? initialComplaint;

  ComplaintDetailsArgs({required this.complaintId, this.initialComplaint});
}

class ComplaintDetailsView extends StatelessWidget {
  final String complaintId;
  final ComplaintModel? initialComplaint;

  const ComplaintDetailsView({
    super.key,
    required this.complaintId,
    this.initialComplaint,
  });

  Widget _buildStatusBadge(BuildContext context, ComplaintStatus status) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw(8), vertical: sh(4)),
      decoration: BoxDecoration(
        color: status.getBgColor(context),
        borderRadius: BorderRadius.circular(sw(16)),
      ),
      child: Text(
        status.translationKey.tr(),
        style: AppTextStyles.regular14.copyWith(
          color: status.getTextColor(context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return BlocBuilder<ComplaintDetailsCubit, ComplaintDetailsState>(
      builder: (context, state) {
        ComplaintModel? complaint = initialComplaint;
        BookingResponseModel? booking;
        bool isLoading = state is ComplaintDetailsLoading;
        String? errorMessage;

        if (state is ComplaintDetailsSuccess) {
          complaint = state.complaint;
          booking = state.booking;
        } else if (state is ComplaintDetailsFailure) {
          errorMessage = state.errMessage;
        }

        final status = complaint != null
            ? complaint.status
            : ComplaintStatus.open;

        return Scaffold(
          backgroundColor: context.colors.screenBG,
          appBar: GenericAppBar(
            title: LocaleKeys.bookings_complaint_details.tr(),
            trailing: complaint != null
                ? _buildStatusBadge(context, status)
                : null,
          ),
          body: Column(
            children: [
              if (isLoading && complaint == null)
                const Expanded(child: Center(child: CustomLoadingIndicator()))
              else if (errorMessage != null && complaint == null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage,
                          style: AppTextStyles.medium16.copyWith(
                            color: context.colors.errorLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<ComplaintDetailsCubit>()
                                .fetchComplaintDetails(complaintId);
                          },
                          child: Text(LocaleKeys.retry.tr()),
                        ),
                      ],
                    ),
                  ),
                )
              else if (complaint != null)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(sw(24)),
                        topRight: Radius.circular(sw(24)),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.all(sw(24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isLoading) ...[
                            const LinearProgressIndicator(),
                            SizedBox(height: sh(16)),
                          ],
                          ComplaintBookingDetailsCard(
                            bookingId: complaint.bookingId,
                            booking: booking,
                            bookingReferenceNumber:
                                complaint.bookingReferenceNumber,
                          ),
                          SizedBox(height: sh(24)),
                          ComplaintDetailsTypeCard(
                            category: complaint.category ?? '',
                          ),
                          SizedBox(height: sh(24)),
                          ComplaintDetailsDescriptionCard(complaint: complaint),
                          SizedBox(height: sh(24)),
                          ComplaintDetailsPhotosCard(
                            photos: complaint.photoObjectKeys ?? [],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
