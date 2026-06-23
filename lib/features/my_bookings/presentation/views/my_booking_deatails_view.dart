import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:svg_flutter/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/enums/payment_status_enum.dart';
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
                                  if (_showsReceipt(activeBooking)) ...[
                                    const SizedBox(height: 16),
                                    _buildReceiptLink(context, activeBooking),
                                  ],
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
    if (booking.status == BookingStatus.ASSIGNED ||
        booking.status == BookingStatus.STARTED ||
        booking.status == BookingStatus.ON_THE_WAY ||
        booking.status == BookingStatus.ARRIVED ||
        booking.status == BookingStatus.CANCELLED) {
      if (booking.scheduledAt == null) return false;
      try {
        final bookingTime = DateTime.parse(booking.scheduledAt!).toLocal();
        final limit = DateTime.now().add(const Duration(hours: 12));
        return bookingTime.isAfter(limit);
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  /// Server-rendered receipt PDF (spec §8). Opened in the device's external
  /// PDF/browser handler — never rendered in-app (Flutter Arabic/RTL PDF
  /// bugs). Shown only for completed bookings whose money actually moved.
  bool _showsReceipt(BookingResponseModel booking) {
    return booking.status == BookingStatus.COMPLETED &&
        (booking.paymentStatus == PaymentStatus.PAID ||
            booking.paymentStatus == PaymentStatus.PARTIALLY_REFUNDED);
  }

  Widget _buildReceiptLink(BuildContext context, BookingResponseModel booking) {
    if (!_showsReceipt(booking) || booking.id == null) {
      return const SizedBox.shrink();
    }
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(
          Endpoints.baseUrl + Endpoints.bookingReceiptPdf(booking.id!),
        );
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!ok && context.mounted) {
          context.showWarningSnackBar(
            context.isAr ? 'تعذّر فتح الإيصال.' : 'Could not open the receipt.',
          );
        }
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

  Widget _buildActionSheet(BuildContext context, BookingResponseModel booking) {
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
}
