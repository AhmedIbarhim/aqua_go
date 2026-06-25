import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';
import '../../../home/data/models/add_on_model.dart';
import '../../data/models/biker_note.dart';
import '../../data/models/package_booking_request_model.dart';
import '../../data/repos/booking_repository.dart';
import '../../presentation/controllers/booking_state.dart';
import 'booking_submit_strategy.dart';

class PackageBookingSubmit implements BookingSubmitStrategy {
  const PackageBookingSubmit();

  @override
  Future<Either<Failure, BookingResponseModel>> submit({
    required BookingRepository repo,
    required BookingState state,
    String? moyasarPaymentId,
  }) async {
    // Build add-ons list
    final List<AddOnModel> addonsList = [];
    final availableAddons = state.selectedService?.addons ?? [];
    for (final idx in state.selectedServiceIndices) {
      if (idx < availableAddons.length) {
        addonsList.add(availableAddons[idx]);
      }
    }

    // Build biker notes list
    final List<String> notesList = [];
    final isArabic =
        CacheClient.getString(kLanguage, defaultValue: kArabicLang) ==
        kArabicLang;

    for (final noteKey in state.bikerNotes) {
      if (noteKey == LocaleKeys.bookings_special_note) {
        if (state.specialNoteText.trim().isNotEmpty) {
          notesList.add(state.specialNoteText.trim());
        }
      } else {
        final enumVal = BikerNote.fromKey(noteKey);
        if (enumVal != null) {
          notesList.add(enumVal.getValue(isArabic));
        }
      }
    }

    final List<String> vehicleIds = [];
    if (state.selectedCar != null) {
      vehicleIds.add(state.selectedCar!.id);
    }

    final packageBooking = PackageBookingRequestModel(
      address: state.selectedAddress,
      date: state.selectedDate,
      time: state.selectedTime,
      vehicleIds: vehicleIds,
      serviceAddOns: addonsList,
      workerNotes: notesList,
      moyasarPaymentId: moyasarPaymentId,
      serviceId: state.selectedPackageService?.id,
    );

    return repo.scheduleSubscriptionWash(
      subscriptionId: state.subscriptionId!,
      washId: state.washId!,
      request: packageBooking,
    );
  }
}
