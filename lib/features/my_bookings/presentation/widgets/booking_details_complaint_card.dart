import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:skeletonizer/skeletonizer.dart';

import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/features/complaints/data/models/complaint_model.dart';
import 'package:aqua_go/features/complaints/data/repos/complaints_repository.dart';
import 'package:aqua_go/features/complaints/presentation/views/complaint_details_view.dart';

import '../../../complaints/data/enums/complaint_category_enum.dart';

class BookingDetailsComplaintCard extends StatefulWidget {
  final String complaintId;

  const BookingDetailsComplaintCard({super.key, required this.complaintId});

  @override
  State<BookingDetailsComplaintCard> createState() =>
      _BookingDetailsComplaintCardState();
}

class _BookingDetailsComplaintCardState
    extends State<BookingDetailsComplaintCard> {
  late Future<dartz.Either<Failure, ComplaintModel>> _complaintFuture;

  @override
  void initState() {
    super.initState();
    _fetchComplaint();
  }

  void _fetchComplaint() {
    _complaintFuture = locator<ComplaintsRepository>().getComplaintDetail(
      widget.complaintId,
    );
  }

  @override
  void didUpdateWidget(covariant BookingDetailsComplaintCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.complaintId != widget.complaintId) {
      setState(() {
        _fetchComplaint();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_complaint.tr(context: context),
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<dartz.Either<Failure, ComplaintModel>>(
          future: _complaintFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState(context);
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _buildErrorState(context, null);
            }

            final result = snapshot.data!;
            return result.fold(
              (failure) => _buildErrorState(context, failure.message),
              (complaint) => _buildSuccessState(context, complaint),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.cardBackGround,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Complaint Category Placeholder',
                  style: AppTextStyles.medium14,
                ),
                const SizedBox(height: 4),
                Text('2026-06-23', style: AppTextStyles.regular12),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[350],
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('Status', style: AppTextStyles.regular12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    final finalMessage = errorMessage != null && errorMessage.isNotEmpty
        ? errorMessage
        : (context.isAr
              ? 'فشل تحميل تفاصيل الشكوى'
              : 'Failed to load complaint details');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.cardBackGround,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              finalMessage,
              style: AppTextStyles.regular14.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: context.colors.primary),
            onPressed: () {
              setState(() {
                _fetchComplaint();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, ComplaintModel complaint) {
    final category = ComplaintCategory.fromString(complaint.category);
    final categoryText = category.translationKey.tr(context: context);
    final status = complaint.status;

    return InkWell(
      onTap: () {
        context.pushNamed(
          Routes.complaintDetails,
          arguments: ComplaintDetailsArgs(
            complaintId: complaint.id,
            initialComplaint: complaint,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.cardBackGround,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    categoryText,
                    style: AppTextStyles.medium14.copyWith(
                      color: context.colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    complaint.getDate(context),
                    style: AppTextStyles.regular12.copyWith(
                      color: context.colors.contentSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status.getBgColor(context),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    status.translationKey.tr(context: context),
                    style: AppTextStyles.regular12.copyWith(
                      color: status.getTextColor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: context.colors.contentDisabled,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
