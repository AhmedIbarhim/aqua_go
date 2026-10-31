import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../data/models/biker_note.dart';
import '../../data/models/package_booking_request_model.dart';
import '../../data/repos/booking_repository.dart';
import '../booking_submission.dart';
import 'booking_submit_strategy.dart';

class PackageBookingSubmit implements PaidBookingSubmitStrategy {
  const PackageBookingSubmit();

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

    final List<String> vehicleIds = [];
    if (submission.selectedCar != null) {
      vehicleIds.add(submission.selectedCar!.id);
    }

    final packageBooking = PackageBookingRequestModel(
      address: submission.selectedAddress,
      slotStart: submission.selectedSlotStart,
      vehicleIds: vehicleIds,
      serviceAddOns: submission.selectedAddons,
      workerNotes: notesList,
      moyasarPaymentId: moyasarPaymentId,
      serviceId: submission.selectedPackageService?.id,
    );

    return repo.scheduleSubscriptionWash(
      subscriptionId: submission.subscriptionId!,
      washId: submission.washId!,
      request: packageBooking,
    );
  }
}
