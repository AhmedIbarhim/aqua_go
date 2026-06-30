import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import '../../data/models/booking_response_model/booking_response_model.dart';

class BookingDetailsWorkerNotesCard extends StatelessWidget {
  final BookingResponseModel booking;

  const BookingDetailsWorkerNotesCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    if (booking.workerNotes == null || booking.workerNotes!.isEmpty) {
      return const SizedBox.shrink();
    }

    final translatedNotes = booking.workerNotes!.map((note) {
      if (context.isAr) {
        if (note == "Don't call") {
          return 'لا تتصل بالهاتف';
        } else if (note == 'Outside wash only') {
          return 'غسيل خارجي فقط';
        } else {
          return note;
        }
      }
      if (context.isEn) {
        if (note == 'لا تتصل بالهاتف') {
          return "Don't call";
        } else if (note == 'غسيل خارجي فقط') {
          return 'Outside wash only';
        } else {
          return note;
        }
      }
      return note;
    }).toList();

    final notesText = translatedNotes.join('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bookings_notes.tr(context: context),
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            notesText,
            style: AppTextStyles.medium16.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
