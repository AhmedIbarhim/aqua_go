import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:aqua_go/features/booking/domain/strategies/reschedule_booking_submit.dart';
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
              title: LocaleKeys.bookings_booking_details.tr(),
              automaticallyImplyLeading: !isFromBookingFlow,
              actions: [
                if (isFromBookingFlow)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      context.pushNamedAndRemoveUntil(Routes.layout);
                    },
                  )
                else if (!activeBooking.isUpcoming)
                  IconButton(
                    onPressed: () => MyBookingProceduresBottomSheet.show(
                      context,
                      activeBooking,
                    ),
                    icon: const Icon(Icons.more_vert),
                  ),
              ],
            ),
            body: Column(
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
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          BookingDetailsNumberCard(booking: activeBooking),
                          const SizedBox(height: 16),
                          BookingDetailsVehicleCard(booking: activeBooking),
                          const SizedBox(height: 16),
                          if (activeBooking.status ==
                              BookingStatus.COMPLETED) ...[
                            BookingDetailsBikerCard(booking: activeBooking),
                            const SizedBox(height: 16),
                          ],
                          BookingDetailsSummaryCard(booking: activeBooking),

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
                          if (activeBooking.status == BookingStatus.COMPLETED)
                            MyBookingPhotosSection(
                              photos: activeBooking.photos,
                            ),
                          const SizedBox(height: 16),
                          _buildInvoicesLink(context, activeBooking),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                if (activeBooking.isUpcoming)
                  _buildActionSheet(context, activeBooking),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvoicesLink(
    BuildContext context,
    BookingResponseModel booking,
  ) {
    if (booking.invoice == null) {
      return const SizedBox.shrink();
    }
    return InkWell(
      onTap: () {
        if (booking.invoice?.pdfUrl != null) {
          // TODO: Open the PDF URL (requires url_launcher package or similar)
          context.showSuccessSnackBar(booking.invoice!.pdfUrl!);
        } else {
          context.showWarningSnackBar(
            context.isAr
                ? "رابط الفاتورة غير متوفر حالياً"
                : "Invoice PDF URL is not available yet.",
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
              LocaleKeys.bookings_go_to_invoice_list.tr(),
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

  Widget _buildActionSheet(BuildContext context, BookingResponseModel booking) {
    return BottomActionSheetContainer(
      child: CustomButton(
        text: LocaleKeys.bookings_edit_booking.tr(),
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
            color: booking.vehicleColor ?? '',
            modelYear: booking.vehicleYear!,
            logoUrl: booking.vehicleMakeLogoUrl ?? '',
            plateNumber: booking.plate ?? '',
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

          context.pushNamed(
            Routes.bookingLocation,
            arguments: BookingFlowStartArgs(
              service: service,
              existingCar: existingCar,
              existingAddress: existingAddress,
              flowConfig: const BookingFlowConfig(
                flowType: BookingFlowType.reschedule,
              ),
              submitStrategy: RescheduleBookingSubmit(
                existingBookingId: booking.id!,
              ),
            ),
          );
        },
      ),
    );
  }
}
