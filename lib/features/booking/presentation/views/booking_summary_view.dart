import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/biker_notes_selection.dart';
import '../widgets/payment_summary_card.dart';
import '../widgets/payment_method_selection.dart';

import '../../controllers/booking_cubit.dart';
import '../../controllers/booking_state.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/features/my_bookings/presentation/views/my_booking_deatails_view.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_summary_model.dart';

class BookingSummaryView extends StatefulWidget {
  const BookingSummaryView({super.key});

  @override
  State<BookingSummaryView> createState() => _BookingSummaryViewState();
}

class _BookingSummaryViewState extends State<BookingSummaryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = context.read<BookingCubit>().state.flowConfig;
      if (config.requiresQuote) {
        context.read<BookingCubit>().fetchQuote();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state.status == BookingStatus.loading) {
          context.showLoadingOverlay();
        } else {
          context.hideLoadingOverlay();
        }

        if (state.status == BookingStatus.success) {
          context.showSuccessSnackBar(LocaleKeys.snackbar_booking_created.tr());
          context
              .showSuccessAlert(
                message: LocaleKeys.bookings_booking_success_message.tr(),
              )
              .then((_) {
                if (!context.mounted) return;
                Navigator.popUntil(context, (route) => route.isFirst);
                if (state.createdBooking != null) {
                  Navigator.pushNamed(
                    context,
                    Routes.myBookingDetails,
                    arguments: MyBookingDetailsArgs(
                      booking: BookingSummaryModel.fromDetails(
                        state.createdBooking!,
                      ),
                      isFromBookingFlow: true,
                    ),
                  );
                }
              });
        } else if (state.status == BookingStatus.failure) {
          context.showErrorSnackBar(state.errorMessage ?? '');
        }
      },
      builder: (context, bookingState) {
        return Scaffold(
          backgroundColor: context.colors.screenBG,
          appBar: GenericAppBar(
            title: LocaleKeys.bookings_booking_summary.tr(),
            hasBackground: true,
            backgroundImage: AppAssets.bookingHeaderImage,
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: _buildContent(context, bookingState, width),
                ),
              ),
              _buildBottomActionSheet(context, bookingState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    BookingState bookingState,
    double width,
  ) {
    final config = bookingState.flowConfig;

    final List<Map<String, dynamic>> selectedAddons = [];
    double addonsGross = 0.0;
    double addonsNet = 0.0;

    final availableAddons = bookingState.selectedService?.addons ?? [];
    for (final idx in bookingState.selectedServiceIndices) {
      if (idx < availableAddons.length) {
        final addon = availableAddons[idx];
        final title = context.isAr
            ? (addon.nameAr ?? addon.nameEn ?? '')
            : (addon.nameEn ?? addon.nameAr ?? '');
        selectedAddons.add({'name': title, 'price': addon.price});
        addonsGross += addon.price;
        addonsNet += (addon.priceMinor ?? 0) / 100;
      }
    }

    final quoteBreakdown = bookingState.quote?.breakdown;

    final double basePrice;
    final double subtotal;
    final double vat;
    final double total;

    if (quoteBreakdown != null) {
      basePrice = quoteBreakdown.net;
      subtotal = quoteBreakdown.net + addonsNet;
      vat = quoteBreakdown.vat;
      total = quoteBreakdown.gross + addonsGross;
    } else {
      basePrice = bookingState.selectedService?.basePriceDouble ?? 0.0;
      subtotal = basePrice + addonsNet;
      vat = (bookingState.selectedService?.vatDouble ?? 0.0);
      total = (bookingState.selectedService?.priceDouble ?? 0.0) + addonsGross;
    }

    return Container(
      padding: EdgeInsets.all(width * 0.06),
      decoration: BoxDecoration(color: context.colors.themeColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config.showBookingSummaryCard) ...[
            _buildSectionTitle(LocaleKeys.bookings_booking_summary.tr()),
            const SizedBox(height: 16),
            BookingSummaryCard(
              serviceName: context.isAr
                  ? (bookingState.selectedService?.rawName.nameAr ?? '')
                  : (bookingState.selectedService?.rawName.nameEn ?? ''),
              carName:
                  '${bookingState.selectedCar!.carMake!.vehicleMakeName.localizedName} ${bookingState.selectedCar!.carModel!.vehicleModelName.localizedName}',
              location: bookingState.selectedAddress?.details ?? '',
              dateTime: bookingState.selectedDate != null
                  ? '${bookingState.selectedDate!.month}/${bookingState.selectedDate!.day}/${bookingState.selectedDate!.year} - ${bookingState.selectedTime ?? ""}'
                  : '',
            ),
            const SizedBox(height: 24),
          ],
          if (config.showBikerNotes) ...[
            _buildSectionTitle(LocaleKeys.bookings_notes_for_biker.tr()),
            const SizedBox(height: 16),
            BikerNotesSelection(
              initialNotes: bookingState.bikerNotes,
              initialSpecialNoteText: bookingState.specialNoteText,
              onNotesChanged: (notes) {
                context.read<BookingCubit>().updateNotes(notes);
              },
              onSpecialNoteTextChanged: (text) {
                context.read<BookingCubit>().updateSpecialNoteText(text);
              },
            ),
            const SizedBox(height: 24),
          ],
          if (config.showPaymentMethod) ...[
            PaymentMethodSelection(
              initialMethod: bookingState.paymentMethod,
              onPaymentMethodChanged: (method) {
                context.read<BookingCubit>().updatePaymentMethod(method);
              },
            ),
            const SizedBox(height: 24),
          ],
          if (config.showPaymentSummary) ...[
            _buildSectionTitle(LocaleKeys.bookings_payment_summary.tr()),
            const SizedBox(height: 16),
            PaymentSummaryCard(
              serviceName: context.isAr
                  ? (bookingState.selectedService?.rawName.nameAr ?? '')
                  : (bookingState.selectedService?.rawName.nameEn ?? ''),
              servicePrice: basePrice,
              additionalItems: selectedAddons,
              subtotal: subtotal,
              vat: vat,
              total: total,
            ),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.regular16.copyWith(
        color: context.colors.textPrimary,
      ),
    );
  }

  Widget _buildBottomActionSheet(
    BuildContext context,
    BookingState bookingState,
  ) {
    final config = bookingState.flowConfig;
    final isEnabled = config.requiresPaymentMethod
        ? bookingState.paymentMethod != null
        : true;

    return BottomActionSheetContainer(
      child: CustomButton(
        text: LocaleKeys.bookings_confirm_booking.tr(),
        enabled: isEnabled,
        onPressed: () {
          context.read<BookingCubit>().submitBooking();
        },
      ),
    );
  }
}
