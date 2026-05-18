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
import '../controllers/booking_cubit.dart';
import '../controllers/booking_state.dart';
import '../widgets/additional_services_grid.dart';

class BookingSummaryView extends StatefulWidget {
  const BookingSummaryView({super.key});

  @override
  State<BookingSummaryView> createState() => _BookingSummaryViewState();
}

class _BookingSummaryViewState extends State<BookingSummaryView> {
  final Set<String> selectedNotes = {};

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
          context.showSuccessAlert().then((_) {
            if (!context.mounted) return;
            Navigator.popUntil(context, (route) => route.isFirst);
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
    final List<Map<String, dynamic>> selectedAddons = [];
    double addonsTotal = 0.0;
    for (final idx in bookingState.selectedServiceIndices) {
      if (idx < AdditionalServicesGrid.additionalServices.length) {
        final item = AdditionalServicesGrid.additionalServices[idx];
        final price = double.tryParse(item['price'] ?? '0.00') ?? 0.00;
        selectedAddons.add({'name': item['title'] ?? '', 'price': price});
        addonsTotal += price;
      }
    }

    final basePrice = 94.99;
    final subtotal = basePrice + addonsTotal;
    final vat = subtotal * 0.15;
    final total = subtotal + vat;

    return Container(
      padding: EdgeInsets.all(width * 0.06),
      decoration: BoxDecoration(color: context.colors.themeColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(LocaleKeys.bookings_booking_summary.tr()),
          const SizedBox(height: 16),
          BookingSummaryCard(
            serviceName: 'غسلة (داخلي و خارجي)',
            carName:
                '${bookingState.selectedCar?.name ?? ''} ${bookingState.selectedCar?.model ?? ''}',
            location: bookingState.selectedAddress?.formattedAddress ?? '',
            dateTime: bookingState.selectedDate != null
                ? '${bookingState.selectedDate!.month}/${bookingState.selectedDate!.day}/${bookingState.selectedDate!.year} - ${bookingState.selectedTime ?? ""}'
                : '',
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(LocaleKeys.bookings_notes_for_biker.tr()),
          const SizedBox(height: 16),
          BikerNotesSelection(
            onNotesChanged: (notes) {
              setState(() {
                selectedNotes.clear();
                selectedNotes.addAll(notes);
              });
              context.read<BookingCubit>().updateNotes(selectedNotes);
            },
          ),
          const SizedBox(height: 24),
          PaymentMethodSelection(
            onPaymentMethodChanged: (method) {
              context.read<BookingCubit>().updatePaymentMethod(method);
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(LocaleKeys.bookings_payment_summary.tr()),
          const SizedBox(height: 16),
          PaymentSummaryCard(
            servicePrice: basePrice,
            additionalItems: selectedAddons,
            subtotal: subtotal,
            vat: vat,
            total: total,
          ),
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
    return BottomActionSheetContainer(
      child: CustomButton(
        text: LocaleKeys.bookings_confirm_booking.tr(),
        onPressed: () {
          context.read<BookingCubit>().submitBooking();
        },
      ),
    );
  }
}
