import 'dart:io';

import 'package:aqua_go/core/components/custom_bottom_sheet.dart';
import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/components/custom_text_field.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/features/complaints/presentation/widgets/complaint_types.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/complaint_model.dart';
import '../../controllers/complaints_cubit/complaints_cubit.dart';
import '../../controllers/complaints_cubit/complaints_state.dart';
import '../widgets/complaint_images_section.dart';

class ComplaintArgs {
  final BookingResponseModel booking;
  ComplaintArgs({required this.booking});
}

class ComplaintView extends StatefulWidget {
  final BookingResponseModel booking;

  const ComplaintView({super.key, required this.booking});

  @override
  State<ComplaintView> createState() => _ComplaintViewState();
}

class _ComplaintViewState extends State<ComplaintView> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  List<File> _selectedImages = [];

  @override
  void dispose() {
    _typeController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _showComplainTypes() {
    CustomBottomSheet.show(
      context: context,
      title: LocaleKeys.bookings_select_complaint_type.tr(),
      child: ComplaintTypes(
        initialValue: _typeController.text,
        onSelected: (value) {
          setState(() {
            _typeController.text = value;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return BlocListener<ComplaintsCubit, ComplaintsState>(
      listener: (context, state) {
        if (state is ComplaintSubmitLoading) {
          context.showLoadingOverlay();
        } else {
          context.hideLoadingOverlay();
        }

        if (state is ComplaintSubmitSuccess) {
          context.showSuccessSnackBar(
            LocaleKeys.bookings_complaint_submitted.tr(),
          );
          Navigator.pop(context, true);
        } else if (state is ComplaintSubmitFailure) {
          context.showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.screenBG,
        appBar: GenericAppBar(
          title: LocaleKeys.bookings_submit_complaint.tr(),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBookingDetailsSection(),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _showComplainTypes,
                      child: AbsorbPointer(
                        child: CustomTextField(
                          label: LocaleKeys.bookings_complaint_type.tr(),
                          hint: LocaleKeys.select_here.tr(),
                          controller: _typeController,
                          isRequired: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailsInput(),
                    const SizedBox(height: 24),

                    ComplaintImagesSection(
                      onImagesChanged: (images) {
                        setState(() {
                          _selectedImages = images;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_booking_details.tr(),
          style: AppTextStyles.regular16,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildDetailRow(
                title: LocaleKeys.bookings_booking_number.tr(),
                value: '#${widget.booking.id}',
                icon: AppAssets.note,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                title: LocaleKeys.bookings_service_name.tr(),
                value: widget.booking.title,
                icon: AppAssets.document,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                title: LocaleKeys.bookings_car_plate.tr(),
                value: widget.booking.plateMasked ?? '',
                icon: AppAssets.boardNum,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                title: LocaleKeys.bookings_date_and_time.tr(),
                value: widget.booking.formattedDateTime,
                icon: AppAssets.date,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                title: LocaleKeys.bookings_worker_name.tr(),
                value: widget.booking.assignedWorker?.displayName ?? '',
                icon: AppAssets.personDisabled,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required String title,
    required String value,
    required dynamic icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                context.colors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.regular12.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.regular12.copyWith(
            color: context.colors.contentSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_complaint_details.tr(),
          style: AppTextStyles.medium14,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _detailsController,
          maxLines: 5,
          textAlign: TextAlign.right,
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: LocaleKeys.write_here.tr(),
            hintStyle: AppTextStyles.regular14.copyWith(
              color: context.colors.contentDisabled,
            ),
            filled: true,
            fillColor: context.colors.themeColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.borderSecondary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.borderSecondary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return BottomActionSheetContainer(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: CustomButton(
              text: LocaleKeys.submit.tr(),
              enabled: _typeController.text.isNotEmpty,
              onPressed: () {
                final category = ComplaintCategory.categoryFromTranslation(_typeController.text).apiValue;
                context.read<ComplaintsCubit>().submitComplaint(
                  bookingId: widget.booking.id ?? '',
                  category: category,
                  description: _detailsController.text,
                  photos: _selectedImages,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: CustomButton(
              text: LocaleKeys.cancel.tr(),
              color: Colors.transparent,
              textColor: context.colors.primary,
              borderColor: context.colors.borderSecondary,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
