import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/config/networking/exceptions/failure.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../data/models/biker_note.dart';
import '../../data/models/service_booking_request_model.dart';
import '../../data/repos/booking_repository.dart';
import '../booking_submission.dart';
import 'booking_submit_strategy.dart';

class ServiceBookingSubmit implements PaidBookingSubmitStrategy {
  @override
  Future<Either<Failure, BookingResponseModel>> submit({
    required BookingRepository repo,
    required BookingSubmission submission,
  }) => _create(repo, submission);

  @override
  Future<Either<Failure, BookingResponseModel>> submitPaid({
    required BookingRepository repo,
    required BookingSubmission submission,
    required String moyasarPaymentId,
  }) => _create(repo, submission, moyasarPaymentId: moyasarPaymentId);

  Future<Either<Failure, BookingResponseModel>> _create(
    BookingRepository repo,
    BookingSubmission submission, {
    String? moyasarPaymentId,
  }) async {
    // Build biker notes list
    final List<String> notesList = [];
    final isArabic =
        CacheClient.getString(kLanguage, defaultValue: kArabicLang) ==
        kArabicLang;

    for (final noteKey in submission.bikerNotes) {
      if (noteKey == LocaleKeys.bookings_special_note) {
        if (submission.specialNoteText.trim().isNotEmpty) {
          notesList.add(submission.specialNoteText.trim());
        }
      } else {
        final enumVal = BikerNote.fromKey(noteKey);
        if (enumVal != null) {
          notesList.add(enumVal.getValue(isArabic));
        }
      }
    }

    final booking = ServiceBookingRequestModel(
      service: submission.selectedService,
      car: submission.selectedCar,
      address: submission.selectedAddress,
      slotStart: submission.selectedSlotStart,
      serviceAddOns: submission.selectedAddons,
      workerNotes: notesList,
      paymentMethod: submission.paymentMethod,
      quote: submission.quote,
      moyasarPaymentId: moyasarPaymentId,
      holdToken: submission.holdToken,
      // Redemption attribution (UCA22 A6): the offer the applied code came
      // through, so the sale is credited to the offer that drove it.
      offerId: submission.appliedOfferId,
    );

    return repo.createBooking(booking);
  }
}
