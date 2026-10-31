import 'dart:async';

import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/features/my_cars/presentation/controllers/my_cars_cubit.dart';
import 'package:aqua_go/features/my_bookings/presentation/views/my_booking_details_view.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_summary_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/booking_details_widgets/package_service_selection_list.dart';
import '../widgets/booking_details_widgets/add_ons_grid.dart';
import '../widgets/booking_details_widgets/date_time_picker.dart';
import '../controllers/booking_cubit.dart';
import '../controllers/booking_payment_cubit.dart';
import '../controllers/booking_payment_state.dart';
import '../controllers/booking_pricing_cubit.dart';
import '../controllers/booking_pricing_state.dart';
import '../controllers/booking_state.dart';
import '../widgets/booking_details_widgets/booking_section_title.dart';
import '../widgets/booking_details_widgets/car_selection_section.dart';
import '../widgets/booking_details_widgets/services_load_error_widget.dart';
import '../widgets/booking_details_widgets/booking_details_bottom_action_sheet.dart';

class BookingDetailsView extends StatefulWidget {
  const BookingDetailsView({super.key});

  @override
  State<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends State<BookingDetailsView> {
  /// Debounce for the price-lock quote refresh fired on each add-on toggle.
  Timer? _quoteDebounce;

  /// Guards the one-shot initial quote fetch so it runs once per screen mount.
  bool _initialQuoteRequested = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final cubit = context.read<BookingCubit>();
      final flowConfig = cubit.state.flowConfig;
      await cubit.refreshCatalog();
      if (!mounted) return;
      if (flowConfig.requiresQuote && !_initialQuoteRequested) {
        _initialQuoteRequested = true;
        _repriceForDisplay();
      }
    });
  }

  @override
  void dispose() {
    _quoteDebounce?.cancel();
    super.dispose();
  }

  void _scheduleQuoteRefresh(BookingState state) {
    if (!state.flowConfig.requiresQuote) return;
    _quoteDebounce?.cancel();
    _quoteDebounce = Timer(
      const Duration(milliseconds: 350),
      _repriceForDisplay,
    );
  }

  void _repriceForDisplay() async {
    if (!mounted) return;
    await context.read<BookingPricingCubit>().repriceForDisplayWithoutPromo();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => locator<MyCarsCubit>()..getCars()),
      ],
      child: MultiBlocListener(
        listeners: [
          // Only handle submit states for reschedule flow (submits from this view)
          BlocListener<BookingPaymentCubit, BookingPaymentState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: _onSubmitStatusChanged,
          ),
          // Reported whatever is on top of this screen: a re-price can land after
          // the customer has moved on. The summary reports it too, and a
          // snackbar replaces the one before it, so they still see one message.
          BlocListener<BookingPricingCubit, BookingPricingState>(
            listenWhen: (previous, current) =>
                previous.status != current.status &&
                current.status == BookingStatus.failure,
            listener: (context, state) {
              context.showErrorSnackBar(state.errorMessage ?? '');
            },
          ),
        ],
        child: BlocBuilder<BookingCubit, BookingState>(
          builder: (context, bookingState) {
            return Scaffold(
              backgroundColor: context.colors.background,
              appBar: GenericAppBar(
                title: bookingState.flowConfig.isReschedule
                    ? LocaleKeys.bookings_reschedule_booking.tr(
                        context: context,
                      )
                    : LocaleKeys.bookings_booking_details.tr(context: context),
                titleColor: context.colors.textPrimary,
                hasBackground: true,
                backgroundImage: context.isDarkTheme
                    ? AppAssets.bookingHeaderImageDark
                    : AppAssets.bookingHeaderImageLight,
                centerTitle: true,
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildContent(
                        context,
                        bookingState,
                        width,
                        height,
                      ),
                    ),
                  ),
                  BookingDetailsBottomActionSheet(bookingState: bookingState),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onSubmitStatusChanged(BuildContext context, BookingPaymentState state) {
    final flowConfig = context.read<BookingCubit>().state.flowConfig;
    if (flowConfig.showSummaryStep) return;

    if (state.status == BookingStatus.success) {
      context.showSuccessSnackBar(
        LocaleKeys.bookings_reschedule_success.tr(context: context),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
      if (state.createdBooking != null) {
        Navigator.pushNamed(
          context,
          Routes.myBookingDetails,
          arguments: MyBookingDetailsArgs(
            booking: BookingSummaryModel.fromDetails(state.createdBooking!),
            isFromBookingFlow: true,
          ),
        );
      }
    } else if (state.status == BookingStatus.failure) {
      context.showErrorSnackBar(state.errorMessage ?? '');
    }
  }

  Widget _buildContent(
    BuildContext context,
    BookingState bookingState,
    double width,
    double height,
  ) {
    final config = bookingState.flowConfig;

    return Container(
      padding: EdgeInsets.all(width * 0.06),
      decoration: BoxDecoration(color: context.colors.background),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingSectionTitle(
            title: LocaleKeys.bookings_choose_car.tr(context: context),
            isRequired: true,
          ),
          SizedBox(height: height * 0.02),
          CarSelectionSection(bookingState: bookingState),
          if (config.isPackage &&
              (bookingState.packageServices.length > 1 ||
                  bookingState.packageServicesLoadFailed)) ...[
            SizedBox(height: height * 0.03),
            BookingSectionTitle(
              title: LocaleKeys.bookings_choose_service.tr(context: context),
              isRequired: true,
            ),
            SizedBox(height: height * 0.02),
            if (bookingState.packageServicesLoadFailed)
              ServicesLoadErrorWidget(width: width)
            else
              PackageServiceSelectionList(
                services: bookingState.packageServices,
                selectedServiceId: bookingState.selectedPackageService?.id,
                onServiceSelected: (service) {
                  context.read<BookingCubit>().selectPackageService(service);
                },
              ),
          ],
          if (config.showAddOns &&
              bookingState.selectedService != null &&
              bookingState.selectedService!.addons.isNotEmpty) ...[
            SizedBox(height: height * 0.03),
            BookingSectionTitle(
              title: LocaleKeys.bookings_additional_services.tr(
                context: context,
              ),
            ),
            SizedBox(height: height * 0.02),
            AddOnsGrid(
              addons: bookingState.selectedService?.addons ?? [],
              selectedIndices: bookingState.selectedServiceIndices,
              onServiceToggled: (index) {
                context.read<BookingCubit>().toggleService(index);
                // Re-lock the price for the new add-on selection (service flow).
                _scheduleQuoteRefresh(bookingState);
              },
              isPackageFlow: config.isPackage,
            ),
          ],
          SizedBox(height: height * 0.02),
          BookingDateTimePicker(
            initialDate: bookingState.selectedDate,
            initialSlotStart: bookingState.selectedSlotStart,
            availabilitySlots: bookingState.availabilitySlots,
            isLoading: bookingState.isAvailabilityLoading,
            onDateChanged: (date) {
              context.read<BookingCubit>().updateDateTime(
                date,
                bookingState.selectedSlotStart,
              );
            },
            onSlotSelected: (slotStart) {
              context.read<BookingCubit>().updateDateTime(
                bookingState.selectedDate,
                slotStart,
              );
            },
          ),
        ],
      ),
    );
  }
}
