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

import '../../data/models/booking_response_model.dart';
import '../../controllers/my_booking_details_cubit.dart';
import '../../controllers/my_booking_details_state.dart';
import '../../../../core/components/bottom_action_sheet_container.dart';
import '../../data/models/booking_status_enum.dart';
import '../widgets/my_booking_procedures_bottom_sheet.dart';
import '../widgets/my_booking_photos_section.dart';
import '../widgets/my_booking_location_section.dart';
import '../widgets/booking_details_number_card.dart';
import '../widgets/booking_details_vehicle_card.dart';
import '../widgets/booking_details_biker_card.dart';
import '../widgets/booking_details_summary_card.dart';

class MyBookingDetailsArgs {
  final BookingResponseModel booking;
  final bool isFromBookingFlow;
  MyBookingDetailsArgs({required this.booking, this.isFromBookingFlow = false});
}

class MyBookingDetailsView extends StatelessWidget {
  final BookingResponseModel booking;
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
            : booking;

        return PopScope(
          canPop: !isFromBookingFlow,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (didPop) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.layout,
              (route) => false,
            );
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
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Routes.layout,
                        (route) => false,
                      );
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
    if (booking.invoice?.pdfUrl == null) {
      return const SizedBox.shrink();
    }
    return Container(
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
        onPressed: () {},
      ),
    );
  }
}
