import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/biker_notes_selection.dart';
import '../widgets/payment_summary_card.dart';
import '../widgets/payment_method_selection.dart';

class BookingSummaryView extends StatefulWidget {
  const BookingSummaryView({super.key});

  @override
  State<BookingSummaryView> createState() => _BookingSummaryViewState();
}

class _BookingSummaryViewState extends State<BookingSummaryView> {
  final Set<String> selectedNotes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.bookings_booking_summary.tr(),
        hasBackground: true,
        backgroundImage: AppAssets.bookingHeaderImage,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildContent(context)),
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),
          _buildBottomActionSheet(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: context.colors.themeColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(LocaleKeys.bookings_booking_summary.tr()),
          const SizedBox(height: 16),
          const BookingSummaryCard(
            serviceName: 'غسلة (داخلي و خارجي)',
            carName: 'تويوتا لاند كروزر',
            location: 'شارع احمد عبد الخالق, نجران السعودية',
            dateTime: ' 9:00 م . 4/22/2026',
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
            },
          ),
          const SizedBox(height: 24),
          PaymentMethodSelection(
            onPaymentMethodChanged: (method) {
              // TODO: Handle payment method change
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(LocaleKeys.bookings_payment_summary.tr()),
          const SizedBox(height: 16),
          const PaymentSummaryCard(
            servicePrice: 0.00,
            additionalItems: [
              {'name': 'مناديل مبللة', 'price': 0.00},
            ],
            subtotal: 0.00,
            vat: 0.00,
            total: 0.00,
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

  Widget _buildBottomActionSheet(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        decoration: BoxDecoration(
          color: context.colors.screenBG,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, -12),
            ),
          ],
        ),
        child: CustomButton(
          text: LocaleKeys.bookings_confirm_booking.tr(),
          onPressed: () {
            // TODO: Handle booking confirmation
          },
        ),
      ),
    );
  }
}
