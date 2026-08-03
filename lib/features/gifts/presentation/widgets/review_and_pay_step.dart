import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../generated/locale_keys.g.dart';
import '../controllers/send_gift_cubit.dart';
import '../controllers/send_gift_state.dart';
import '../../../home/data/models/add_on_model.dart';
import '../../../../core/enums/payment_method_enum.dart';
import 'gift_payment_method_card.dart';
import 'gift_invoice_row.dart';

class ReviewAndPayStep extends StatelessWidget {
  const ReviewAndPayStep({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isIOS = !kIsWeb && Platform.isIOS;

    return BlocBuilder<SendGiftCubit, SendGiftState>(
      builder: (context, state) {
        if (state.selectedService == null) {
          return const SizedBox.shrink();
        }

        final service = state.selectedService!;
        final quote = state.quote;

        double servicePrice = service.priceDouble / 1.15;
        final List<Map<String, dynamic>> selectedAddons = [];

        final List<AddOnModel> selectedAddonsList = service.addons
            .where((addon) => state.selectedAddonIds.contains(addon.id))
            .toList();
        for (final addon in selectedAddonsList) {
          selectedAddons.add({
            'name': context.isAr
                ? (addon.nameAr ?? '')
                : (addon.nameEn ?? ''),
            'price': addon.price / 1.15,
          });
        }

        final double subtotal;
        final double vat;
        final double totalAmount;

        if (quote != null) {
          subtotal = quote.breakdown?.net ?? 0.0;
          vat = quote.breakdown?.vat ?? 0.0;
          totalAmount = quote.cardCharge;
        } else {
          // Fallback calculations
          final rawTotal =
              service.priceDouble +
              service.addons
                  .where((addon) => state.selectedAddonIds.contains(addon.id))
                  .fold<double>(0.0, (sum, addon) => sum + addon.price);
          subtotal = rawTotal / 1.15;
          vat = rawTotal - subtotal;
          totalAmount = rawTotal;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Recipient Info ---
            _buildSectionHeader(
              context,
              context.isAr ? "بيانات المستلم" : "Recipient Info",
            ),
            SizedBox(height: context.sh(12)),
            Container(
              padding: EdgeInsets.all(context.sw(16)),
              decoration: BoxDecoration(
                color: context.colors.cardBackGround,
                borderRadius: BorderRadius.circular(context.sw(12)),
                border: Border.all(color: context.colors.borderSecondary),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    label: context.isAr ? "الاسم" : "Name",
                    value: state.recipientName.isNotEmpty
                        ? state.recipientName
                        : "---",
                  ),
                  SizedBox(height: context.sh(12)),
                  _buildDetailRow(
                    context,
                    label: context.isAr ? "رقم الجوال" : "Mobile Number",
                    value: state.recipientPhone.isNotEmpty
                        ? state.recipientPhone
                        : "---",
                  ),
                ],
              ),
            ),
            SizedBox(height: context.sh(24)),

            // --- Gift Details ---
            _buildSectionHeader(
              context,
              context.isAr ? "تفاصيل الهدية" : "Gift Details",
            ),
            SizedBox(height: context.sh(12)),
            Container(
              padding: EdgeInsets.all(context.sw(16)),
              decoration: BoxDecoration(
                color: context.colors.cardBackGround,
                borderRadius: BorderRadius.circular(context.sw(12)),
                border: Border.all(color: context.colors.borderSecondary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    context,
                    label: context.isAr ? "اسم الخدمة" : "Service Name",
                    value: context.isAr
                        ? (service.rawName?.nameAr ?? '')
                        : (service.rawName?.nameEn ?? ''),
                  ),
                  SizedBox(height: context.sh(12)),
                  _buildDetailRow(
                    context,
                    label: context.isAr ? "التسليم" : "Delivery",
                    value: state.deliveryType == 'IMMEDIATE'
                        ? (context.isAr ? "فوري" : "Immediate")
                        : "${context.isAr ? "مجدول" : "Scheduled"}:"
                              " ${formatPickedTime(state.scheduledTime!)}"
                              " . ${formatShortDate(state.scheduledDate!)}",
                  ),
                  SizedBox(height: context.sh(12)),
                  _buildDetailRow(
                    context,
                    label: context.isAr ? "تصميم البطاقة" : "Card Design",
                    value: state.selectedTheme != null
                        ? (context.isAr
                              ? (state.selectedTheme!.nameAr ??
                                    state.selectedTheme!.nameEn ??
                                    '')
                              : (state.selectedTheme!.nameEn ??
                                    state.selectedTheme!.nameAr ??
                                    ''))
                        : "---",
                  ),
                  if (state.messageText.trim().isNotEmpty) ...[
                    SizedBox(height: context.sh(12)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.isAr ? "الرسالة المرسلة" : "Sent Message",
                          style: AppTextStyles.regular14.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        SizedBox(height: context.sh(8)),
                        Text(
                          "“${state.messageText}”",
                          style: AppTextStyles.medium14.copyWith(
                            color: context.colors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: context.sh(24)),

            // --- Addons ---
            if (selectedAddons.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                context.isAr ? "الإضافات" : "Add-ons",
              ),
              SizedBox(height: context.sh(12)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.sw(16)),
                decoration: BoxDecoration(
                  color: context.colors.cardBackGround,
                  borderRadius: BorderRadius.circular(context.sw(12)),
                  border: Border.all(color: context.colors.borderSecondary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < selectedAddons.length; i++) ...[
                      if (i > 0) SizedBox(height: context.sh(12)),
                      Text(
                        selectedAddons[i]['name'] ?? '',
                        style: AppTextStyles.medium14.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: context.sh(24)),
            ],

            // --- Payment Method Selection ---
            Text(
              LocaleKeys.bookings_pay_through.tr(context: context),
              style: AppTextStyles.medium16.copyWith(
                fontSize: context.sw(16),
                color: context.colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.sh(12)),
            if (isIOS) ...[
              GiftPaymentMethodCard(
                method: PaymentMethod.applePay,
                title: LocaleKeys.bookings_apple_pay.tr(context: context),
                iconPaths: [AppAssets.applePay],
                isSelected: state.paymentMethod == PaymentMethod.applePay,
              ),
              SizedBox(height: context.sh(12)),
            ],
            GiftPaymentMethodCard(
              method: PaymentMethod.creditCard,
              title: LocaleKeys.bookings_credit_card.tr(context: context),
              iconPaths: [
                AppAssets.visaPay,
                AppAssets.mastercardPay,
                AppAssets.madaPay,
              ],
              isSelected: state.paymentMethod == PaymentMethod.creditCard,
            ),

            SizedBox(height: context.sh(24)),

            // --- Payment Invoice Breakdown ---
            Text(
              LocaleKeys.gifts_payment_summary.tr(context: context),
              style: AppTextStyles.medium16.copyWith(
                fontSize: context.sw(16),
                color: context.colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.sh(12)),
            Container(
              padding: EdgeInsets.all(context.sw(16)),
              decoration: BoxDecoration(
                color: context.colors.cardBackGround,
                borderRadius: BorderRadius.circular(context.sw(16)),
                border: Border.all(color: context.colors.borderSecondary),
              ),
              child: Column(
                children: [
                  GiftInvoiceRow(
                    label: context.isAr
                        ? (service.rawName?.nameAr ?? '')
                        : (service.rawName?.nameEn ?? ''),
                    amount: servicePrice,
                  ),
                  for (final item in selectedAddons) ...[
                    SizedBox(height: context.sh(12)),
                    GiftInvoiceRow(label: item['name'], amount: item['price']),
                  ],
                  SizedBox(height: context.sh(12)),
                  Divider(color: context.colors.borderSecondary),
                  SizedBox(height: context.sh(12)),
                  GiftInvoiceRow(
                    label: LocaleKeys.gifts_subtotal.tr(context: context),
                    amount: subtotal,
                  ),
                  SizedBox(height: context.sh(12)),
                  GiftInvoiceRow(
                    label: LocaleKeys.gifts_vat.tr(context: context),
                    amount: vat,
                  ),
                  if (quote != null && quote.pointsDiscountMinor > 0) ...[
                    SizedBox(height: context.sh(12)),
                    GiftInvoiceRow(
                      label: context.isAr ? "خصم النقاط" : "Points Discount",
                      amount: -quote.pointsDiscount,
                    ),
                  ],
                  SizedBox(height: context.sh(12)),
                  Divider(color: context.colors.textPrimary, thickness: 1),
                  SizedBox(height: context.sh(12)),
                  GiftInvoiceRow(
                    label: LocaleKeys.gifts_total_price.tr(context: context),
                    amount: totalAmount,
                    isTotal: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: context.sh(24)),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.bold16.copyWith(
        fontSize: context.sw(16),
        color: context.colors.textPrimary,
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.medium14.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
