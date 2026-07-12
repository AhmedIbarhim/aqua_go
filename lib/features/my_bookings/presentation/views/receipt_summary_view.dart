import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/components/bottom_action_sheet_container.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import '../widgets/receipt_number_card.dart';
import '../widgets/receipt_client_details_card.dart';
import '../widgets/receipt_booking_details_card.dart';
import '../widgets/receipt_addons_card.dart';
import '../widgets/receipt_payment_method_card.dart';
import '../widgets/receipt_payment_summary_card.dart';

class ReceiptSummaryView extends StatelessWidget {
  final BookingResponseModel booking;

  const ReceiptSummaryView({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    final hasAddons = booking.addOns != null && booking.addOns!.isNotEmpty;

    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.receipt_title.tr(context: context),
        automaticallyImplyLeading: false,
        centerTitle: false,
        leading: context.isAr
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
        actions: context.isAr
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: sw(24),
                vertical: sh(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card 1: Receipt/Invoice Number with Green Paid ribbon
                  ReceiptNumberCard(booking: booking),
                  SizedBox(height: sh(16)),

                  // Card 2: Client Info Card
                  ReceiptClientDetailsCard(booking: booking),
                  SizedBox(height: sh(16)),

                  // Card 3: Booking Info Card
                  ReceiptBookingDetailsCard(booking: booking),
                  SizedBox(height: sh(16)),

                  // Card 4: Booking Add-ons Card (if any add-ons are present)
                  if (hasAddons) ...[
                    ReceiptAddonsCard(booking: booking),
                    SizedBox(height: sh(16)),
                  ],

                  // Card 5: Payment Method Card
                  ReceiptPaymentMethodCard(booking: booking),
                  SizedBox(height: sh(16)),

                  // Card 6: Payment Summary Card
                  ReceiptPaymentSummaryCard(booking: booking),
                  SizedBox(height: sh(32)),
                ],
              ),
            ),
          ),
          // Download Action Button
          _buildDownloadButton(context, sw, sh),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(
    BuildContext context,
    double Function(double) sw,
    double Function(double) sh,
  ) {
    final downloadIcon = Container(
      padding: EdgeInsets.all(sw(2)),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Icon(Icons.arrow_downward, size: sw(14), color: Colors.black),
    );

    return BottomActionSheetContainer(
      child: CustomButton(
        text: LocaleKeys.receipt_download.tr(context: context),
        preWidget: context.isAr ? downloadIcon : null,
        postWidget: context.isAr ? null : downloadIcon,
        onPressed: () async {
          if (booking.id == null) return;
          final uri = Uri.parse(
            Endpoints.baseUrl + Endpoints.bookingReceiptPdf(booking.id!),
          );
          final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!ok && context.mounted) {
            context.showWarningSnackBar(
              LocaleKeys.receipt_error_download.tr(context: context),
            );
          }
        },
      ),
    );
  }
}
