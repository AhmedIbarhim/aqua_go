import 'dart:io';

import '../../../../core/enums/payment_status_enum.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/components/bottom_action_sheet_container.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/services/receipt_files_channel.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/features/my_bookings/data/repos/my_bookings_repository.dart';
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
          // Only PAID bookings have a receipt: the endpoint 422s on anything
          // else, and NOT_REQUIRED (gift redemption, subscription-covered wash)
          // took no payment on this booking to receipt at all.
          if (booking.paymentStatus == PaymentStatus.PAID)
            _DownloadReceiptButton(booking: booking),
        ],
      ),
    );
  }
}

class _DownloadReceiptButton extends StatefulWidget {
  const _DownloadReceiptButton({required this.booking});

  final BookingResponseModel booking;

  @override
  State<_DownloadReceiptButton> createState() => _DownloadReceiptButtonState();
}

class _DownloadReceiptButtonState extends State<_DownloadReceiptButton> {
  bool _downloading = false;

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);

    final downloadIcon = _downloading
        ? SizedBox(
            width: sw(18),
            height: sw(18),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          )
        : Container(
            padding: EdgeInsets.all(sw(2)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Icon(
              Icons.arrow_downward,
              size: sw(14),
              color: Colors.black,
            ),
          );

    return BottomActionSheetContainer(
      child: CustomButton(
        text: LocaleKeys.receipt_download.tr(context: context),
        enabled: !_downloading,
        preWidget: context.isAr ? downloadIcon : null,
        postWidget: context.isAr ? null : downloadIcon,
        onPressed: _downloading ? null : _download,
      ),
    );
  }

  Future<void> _download() async {
    final bookingId = widget.booking.id;
    if (bookingId == null) return;

    setState(() => _downloading = true);
    try {
      final result = await locator<MyBookingsRepository>().downloadReceiptPdf(
        bookingId,
      );
      if (!mounted) return;

      final bytes = result.fold<Uint8List?>((failure) {
        context.showWarningSnackBar(failure.message);
        return null;
      }, (bytes) => bytes);
      if (bytes == null) return;

      final referenceNumber = widget.booking.referenceNumber ?? bookingId;
      final filename = 'AquaGo-$referenceNumber.pdf';

      final docsDir = await getApplicationDocumentsDirectory();
      final privateFile = File('${docsDir.path}/$filename');
      await privateFile.writeAsBytes(bytes, flush: true);

      final reveal = await ReceiptFilesChannel.saveAndReveal(
        bytes: bytes,
        filename: filename,
        mimeType: 'application/pdf',
      );
      if (!mounted) return;
      if (reveal is ReceiptRevealPermissionDenied) {
        context.showWarningSnackBar(
          LocaleKeys.receipt_storage_permission_denied.tr(context: context),
        );
      }

      final openedNatively = await ReceiptFilesChannel.openFile(
        privateFile.path,
      );
      if (!mounted) return;
      if (openedNatively) return;

      final openResult = await OpenFile.open(
        privateFile.path,
        type: 'application/pdf',
      );
      if (!mounted) return;
      if (openResult.type != ResultType.done) {
        context.showWarningSnackBar(
          LocaleKeys.receipt_error_download.tr(context: context),
        );
      }
    } catch (_) {
      if (mounted) {
        context.showWarningSnackBar(
          LocaleKeys.receipt_error_download.tr(context: context),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }
}
