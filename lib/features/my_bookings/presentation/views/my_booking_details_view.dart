import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:svg_flutter/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';

import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/route/app_router.dart';
import 'package:aqua_go/features/booking/domain/configs/booking_flow_config.dart';
import 'package:aqua_go/features/booking/domain/strategies/service_reschedule_booking_submit.dart';
import 'package:aqua_go/features/my_cars/data/models/my_car_model.dart';
import 'package:aqua_go/features/address/data/models/address_model.dart';
import 'package:aqua_go/features/home/data/models/service_model.dart';

import '../../data/models/booking_response_model/booking_response_model.dart';
import '../../data/models/booking_summary_model.dart';
import '../controllers/my_booking_details_cubit.dart';
import '../controllers/my_booking_details_state.dart';
import '../../../../core/components/bottom_action_sheet_container.dart';
import '../../data/enums/booking_status_enum.dart';
import '../widgets/my_booking_procedures_bottom_sheet.dart';
import '../widgets/my_booking_photos_section.dart';
import '../widgets/my_booking_location_section.dart';
import '../widgets/booking_details_number_card.dart';
import '../widgets/booking_details_vehicle_card.dart';
import '../widgets/booking_details_biker_card.dart';
import '../widgets/booking_details_summary_card.dart';
import '../widgets/booking_details_worker_notes_cart.dart';
import '../widgets/booking_details_rating_card.dart';
import '../widgets/booking_details_complaint_card.dart';

class MyBookingDetailsArgs {
  final BookingSummaryModel booking;
  final bool isFromBookingFlow;
  MyBookingDetailsArgs({required this.booking, this.isFromBookingFlow = false});
}

class MyBookingDetailsView extends StatelessWidget {
  final BookingSummaryModel booking;
  final bool isFromBookingFlow;

  const MyBookingDetailsView({
    super.key,
    required this.booking,
    this.isFromBookingFlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBookingDetailsCubit, MyBookingDetailsState>(
      builder: (context, state) {
        final bool isLoading =
            state is MyBookingDetailsLoading ||
            state is MyBookingDetailsInitial;
        final bool isFailure = state is MyBookingDetailsFailure;
        final activeBooking = state is MyBookingDetailsSuccess
            ? state.booking
            : booking.toDetailsPlaceholder();

        return PopScope(
          canPop: !isFromBookingFlow,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (didPop) return;
            context.pushNamedAndRemoveUntil(Routes.layout);
          },
          child: Scaffold(
            backgroundColor: context.colors.screenBG,
            appBar: GenericAppBar(
              title: LocaleKeys.bookings_booking_details.tr(context: context),
              automaticallyImplyLeading: !isFromBookingFlow,
              actions: [
                if (isFromBookingFlow)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      context.pushNamedAndRemoveUntil(Routes.layout);
                    },
                  )
                else if (!isLoading &&
                    !isFailure &&
                    !activeBooking.isUpcoming &&
                    activeBooking.status != BookingStatus.CANCELLED) ...[
                  IconButton(
                    onPressed: () => MyBookingProceduresBottomSheet.show(
                      context,
                      activeBooking,
                    ),
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ],
            ),
            body: isFailure
                ? _buildErrorState(context, state.errMessage)
                : Column(
                    children: [
                      if (state is MyBookingDetailsLoading)
                        const LinearProgressIndicator(),
                      Expanded(
                        child: RefreshIndicator(
                          color: context.colors.primary,
                          onRefresh: () async {
                            await context
                                .read<MyBookingDetailsCubit>()
                                .fetchBookingDetails(activeBooking.id ?? '');
                          },
                          child: Skeletonizer(
                            enabled: isLoading,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  BookingDetailsNumberCard(
                                    booking: activeBooking,
                                  ),
                                  if (activeBooking.complaintId != null &&
                                      activeBooking
                                          .complaintId!
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    BookingDetailsComplaintCard(
                                      key: ValueKey(
                                        activeBooking.updatedAt ??
                                            activeBooking.complaintId,
                                      ),
                                      complaintId: activeBooking.complaintId!,
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  BookingDetailsVehicleCard(
                                    booking: activeBooking,
                                  ),
                                  const SizedBox(height: 16),
                                  if (_showsBikerCard(
                                    activeBooking.status,
                                  )) ...[
                                    BookingDetailsBikerCard(
                                      booking: activeBooking,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  BookingDetailsSummaryCard(
                                    booking: activeBooking,
                                  ),
                                  if (activeBooking.workerNotes != null &&
                                      activeBooking
                                          .workerNotes!
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    BookingDetailsWorkerNotesCard(
                                      booking: activeBooking,
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  if (activeBooking.status !=
                                      BookingStatus.COMPLETED) ...[
                                    const SizedBox(height: 16),
                                    MyBookingLocationSection(
                                      address: activeBooking.location,
                                      latitude: activeBooking.latitude,
                                      longitude: activeBooking.longitude,
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  if (activeBooking.status ==
                                      BookingStatus.COMPLETED)
                                    MyBookingPhotosSection(
                                      photos: activeBooking.photos,
                                    ),
                                  if (activeBooking.rating != null) ...[
                                    const SizedBox(height: 16),
                                    BookingDetailsRatingCard(
                                      rating: activeBooking.rating!,
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  _buildReceiptLink(context, activeBooking),
                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!isLoading && _shouldShowActionSheet(activeBooking))
                        _buildActionSheet(context, activeBooking),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: context.colors.error),
            const SizedBox(height: 16),
            Text(
              message.isNotEmpty
                  ? message
                  : (context.isAr
                        ? 'تعذّر تحميل تفاصيل الحجز'
                        : 'Failed to load booking details'),
              textAlign: TextAlign.center,
              style: AppTextStyles.regular14.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: LocaleKeys.retry.tr(context: context),
              onPressed: () {
                context.read<MyBookingDetailsCubit>().fetchBookingDetails(
                  booking.id ?? '',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _showsBikerCard(BookingStatus? status) {
    switch (status) {
      case BookingStatus.ASSIGNED:
      case BookingStatus.ON_THE_WAY:
      case BookingStatus.ARRIVED:
      case BookingStatus.CANT_FIND_CLIENT:
      case BookingStatus.STARTED:
      case BookingStatus.COMPLETED:
        return true;
      case BookingStatus.PENDING:
      case BookingStatus.UNSCHEDULED:
      case BookingStatus.CANCELLED:
      case null:
        return false;
    }
  }

  bool _shouldShowActionSheet(BookingResponseModel booking) {
    if (!booking.isUpcoming) return false;
    // In-progress / terminal statuses are never reschedulable — hide the sheet
    // entirely (no locked affordance). ASSIGNED is NOT here: the backend now
    // reschedules ASSIGNED bookings (auto-unassigns the worker + emails admin),
    // so it must show the Edit button like PENDING. The < 12h window only
    // LOCKS the button (handled by _isEditable → _buildEditClosedRow); it does
    // not hide the affordance.
    if (booking.status == BookingStatus.STARTED ||
        booking.status == BookingStatus.ON_THE_WAY ||
        booking.status == BookingStatus.ARRIVED ||
        booking.status == BookingStatus.CANCELLED) {
      return false;
    }
    return true;
  }

  /// Server-rendered receipt PDF (spec §8). Opened in the device's external
  /// PDF/browser handler — never rendered in-app (Flutter Arabic/RTL PDF
  /// bugs). Shown only for completed bookings whose money actually moved.
  // bool _showsReceipt(BookingResponseModel booking) {
  //   return booking.status == BookingStatus.COMPLETED &&
  //       (booking.paymentStatus == PaymentStatus.PAID ||
  //           booking.paymentStatus == PaymentStatus.PARTIALLY_REFUNDED);
  // }

  Widget _buildReceiptLink(BuildContext context, BookingResponseModel booking) {
    if (booking.id == null) {
      return const SizedBox.shrink();
    }
    return InkWell(
      onTap: () {
        context.pushNamed(Routes.receiptSummary, arguments: booking);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.themeColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.bookings_view_receipt.tr(context: context),
              style: AppTextStyles.medium14.copyWith(
                color: context.colors.primary,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: context.colors.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeSlot(DateTime time, BuildContext context) {
    if (context.isAr) {
      final hour = time.hour;
      final minute = time.minute;
      final minStr = minute.toString().padLeft(2, '0');

      String period;
      int displayHour = hour;
      if (hour >= 12) {
        period = hour == 12 ? 'ظهراً' : 'مساءً';
        if (hour > 12) displayHour = hour - 12;
      } else {
        period = 'صباحاً';
        if (hour == 0) displayHour = 12;
      }

      return '$displayHour:$minStr $period';
    } else {
      return DateFormat('h:mm a').format(time);
    }
  }

  /// Mirrors the backend reschedule policy (AQG-119:
  /// reschedulePolicy.minHoursBeforeStart = 12h). Editing launches the
  /// reschedule flow, which the server rejects (RescheduleTooLateException)
  /// once the booking is within 12h of its scheduled start (or already past).
  /// Gate the button client-side so the user never hits that server error.
  ///
  /// Defensive: if [scheduledAt] is missing or unparseable we do NOT block —
  /// an unknown time must not break an otherwise-valid read path.
  bool _isEditable(BookingResponseModel booking) {
    final raw = booking.scheduledAt;
    if (raw == null) return false;
    final scheduled = DateTime.tryParse(raw);
    if (scheduled == null) return true;
    final reschedulableStatus =
        booking.status == BookingStatus.PENDING ||
        booking.status == BookingStatus.ASSIGNED;
    if (!reschedulableStatus) return false;
    return scheduled.toLocal().difference(DateTime.now()) >
        const Duration(hours: 12);
  }

  Widget _buildActionSheet(BuildContext context, BookingResponseModel booking) {
    if (!_isEditable(booking)) {
      return _buildEditClosedRow(context);
    }
    return BottomActionSheetContainer(
      child: CustomButton(
        text: LocaleKeys.bookings_edit_booking.tr(context: context),
        postWidget: SvgPicture.asset(
          AppAssets.edit,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            darkAppColors.contentBlack,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () {
          final existingAddress = AddressModel(
            id: null,
            label: booking.addressLabel ?? '',
            details: booking.addressLabel ?? '',
            lat: (booking.addressLat ?? 0.0).toDouble(),
            lng: (booking.addressLng ?? 0.0).toDouble(),
            arrivalNotes: booking.addressArrivalNotes,
            zoneId: booking.zoneId,
          );

          final existingCar = MyCarModel(
            color: booking.vehicles?.firstOrNull?.vehicleColor ?? '',
            modelYear: booking.vehicles?.firstOrNull?.vehicleYear ?? 0,
            logoUrl: booking.vehicles?.firstOrNull?.makeLogoUrl ?? '',
            plateNumber:
                booking.plate ?? booking.vehicles?.firstOrNull?.plate ?? '',
          );

          final service = ServiceModel(
            id: booking.packageId ?? '',
            code: booking.referenceNumber ?? '',
            refNumber: booking.referenceNumber ?? '',
            rawName: ServiceName(
              nameAr: booking.packageName?.ar ?? '',
              nameEn: booking.packageName?.en ?? '',
            ),
          );

          DateTime? existingDate;
          String? existingTime;
          if (booking.scheduledAt != null) {
            final parsedDate = DateTime.tryParse(booking.scheduledAt!);
            if (parsedDate != null) {
              existingDate = parsedDate;
              existingTime = _formatTimeSlot(parsedDate, context);
            }
          }

          context.pushNamed(
            Routes.bookingLocation,
            arguments: BookingFlowStartArgs(
              service: service,
              existingCar: existingCar,
              existingAddress: existingAddress,
              existingDate: existingDate,
              existingTime: existingTime,
              flowConfig: const BookingFlowConfig(
                flowType: BookingFlowType.reschedule,
              ),
              submitStrategy: ServiceRescheduleBookingSubmit(
                existingBookingId: booking.id!,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Muted, non-tappable replacement for the Edit button when the 12h
  /// reschedule window has closed. Same container + height as the active
  /// button so the layout does not shift.
  Widget _buildEditClosedRow(BuildContext context) {
    return BottomActionSheetContainer(
      child: Container(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height * 0.055,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: context.colors.brandSubtle,
          border: Border.all(color: context.colors.borderSecondary, width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Icon(
              Icons.lock_clock_outlined,
              size: 18,
              color: context.colors.contentDisabled,
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  LocaleKeys.bookings_edit_closed_12h.tr(context: context),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regular14.copyWith(
                    color: context.colors.contentDisabled,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
