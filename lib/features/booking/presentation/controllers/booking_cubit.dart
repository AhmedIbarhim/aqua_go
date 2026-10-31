import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/payment_method_enum.dart';
import '../../../../core/utils/saudi_wire_format.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../address/data/models/address_model.dart';
import '../../../home/data/models/service_model.dart';
import '../../../home/data/repos/services_repository.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../../../subscriptions/data/repos/subscriptions_repository.dart';
import '../../data/mappers/subscription_catalog_mapper.dart';
import '../../data/repos/booking_repository.dart';
import '../../domain/addon_selection.dart';
import '../../domain/configs/booking_flow_config.dart';
import 'booking_state.dart';
import 'closed_safe_emit.dart';

export '../../domain/addon_selection.dart';

/// What is being booked: the service, add-ons, car, address, slot and notes,
/// plus the catalog and availability behind those choices.
class BookingCubit extends Cubit<BookingState>
    with ClosedSafeEmit<BookingState> {
  final BookingRepository _bookingRepo;
  final SubscriptionsRepository _subscriptionsRepo;
  final ServicesRepository _servicesRepo;
  final BookingFlowConfig _flowConfig;

  /// Identifies the newest availability lookup, so a slower earlier one can
  /// tell it has been superseded.
  int _availabilityRequestId = 0;

  BookingCubit({
    required BookingRepository bookingRepo,
    required SubscriptionsRepository subscriptionsRepo,
    required ServicesRepository servicesRepo,
    BookingFlowConfig flowConfig = BookingFlowConfig.normal,
  }) : _bookingRepo = bookingRepo,
       _subscriptionsRepo = subscriptionsRepo,
       _servicesRepo = servicesRepo,
       _flowConfig = flowConfig,
       super(BookingState(flowConfig: flowConfig));

  void _emitFailure(String message) {
    emit(state.copyWith(status: BookingStatus.failure, errorMessage: message));
  }

  void initBooking(
    ServiceModel? service, {
    MyCarModel? existingCar,
    AddressModel? existingAddress,
    DateTime? existingDate,
    DateTime? existingSlotStart,
    String? subscriptionId,
    String? washId,
    String? giftCode,
  }) {
    emit(
      BookingState(
        status: BookingStatus.initial,
        selectedService: service,
        selectedCar: existingCar,
        selectedAddress: existingAddress,
        selectedDate: existingDate,
        selectedSlotStart: existingSlotStart,
        flowConfig: _flowConfig,
        subscriptionId: subscriptionId,
        washId: washId,
        giftCode: giftCode,
      ),
    );

    if (subscriptionId != null) {
      fetchSubscriptionDetails(subscriptionId);
    }

    if (existingDate != null) {
      fetchAvailability(targetDate: existingDate);
    }
  }

  Future<void> fetchSubscriptionDetails(String subscriptionId) async {
    emit(state.copyWith(status: BookingStatus.loading));
    final result = await _subscriptionsRepo.fetchSubscriptionDetail(
      subscriptionId: subscriptionId,
    );

    result.fold((failure) => _emitFailure(failure.message), (subscription) {
      final catalog = subscriptionCatalogFrom(
        subscription,
        preferredWashId: state.washId,
      );
      if (catalog == null) {
        _emitFailure(LocaleKeys.bookings_no_washes_available.tr());
        return;
      }

      emit(
        state.copyWith(
          status: BookingStatus.initial,
          selectedService: catalog.service,
          // A refresh can reorder the add-ons, and selections are positional.
          selectedServiceIndices: remapAddonSelections(
            state.selectedService?.addons ?? const [],
            state.selectedServiceIndices,
            catalog.service.addons,
          ),
          washId: catalog.washId,
          subscriptionId: subscriptionId,
          includedAddonIds: catalog.includedAddonIds,
          optionalAddonIds: catalog.optionalAddonIds,
        ),
      );

      _publishPackageServices(subscription.packageInfo.bundledServices);
    });
  }

  void _publishPackageServices(List<ServiceModel> bundledServices) {
    if (bundledServices.isEmpty) {
      emit(state.copyWith(packageServicesLoadFailed: true));
      return;
    }

    emit(
      state.copyWith(
        packageServices: bundledServices,
        packageServicesLoadFailed: false,
        // Auto-select when exactly one included service exists.
        selectedPackageService: bundledServices.length == 1
            ? bundledServices.first
            : null,
      ),
    );
  }

  Future<void> refreshCatalog() async {
    if (state.flowConfig.isPackage) {
      await retryPackageServices();
      return;
    }
    if (!state.flowConfig.isNormal) return;
    final current = state.selectedService;
    if (current == null || current.id == null) return;

    final result = await _servicesRepo.fetchServices();
    result.fold((_) {}, (services) {
      final fresh = services.where((s) => s.id == current.id).firstOrNull;
      if (fresh == null) return;
      emit(
        state.copyWith(
          selectedService: fresh,
          selectedServiceIndices: remapAddonSelections(
            current.addons,
            state.selectedServiceIndices,
            fresh.addons,
          ),
        ),
      );
    });
  }

  Future<void> retryPackageServices() async {
    final subscriptionId = state.subscriptionId;
    if (subscriptionId == null) return;
    await fetchSubscriptionDetails(subscriptionId);
  }

  /// Records the customer's chosen included service for a package wash.
  void selectPackageService(ServiceModel service) {
    emit(state.copyWith(selectedPackageService: service, clearError: true));
  }

  void selectAddress(AddressModel address) {
    final defaultDate = state.selectedDate ?? DateTime.now();
    emit(
      state.copyWith(
        selectedAddress: address,
        selectedDate: defaultDate,
        clearError: true,
      ),
    );
    if (state.selectedService != null) {
      fetchAvailability(targetDate: defaultDate);
    }
  }

  void selectCar(MyCarModel car) {
    emit(state.copyWith(selectedCar: car, clearError: true));
  }

  void toggleService(int serviceIndex) {
    final updatedServices = Set<int>.from(state.selectedServiceIndices);
    if (updatedServices.contains(serviceIndex)) {
      updatedServices.remove(serviceIndex);
    } else {
      updatedServices.add(serviceIndex);
    }
    emit(
      state.copyWith(selectedServiceIndices: updatedServices, clearError: true),
    );
  }

  /// [slotStart] is the availability slot's own `start` instant — never a
  /// display label.
  void updateDateTime(DateTime? date, DateTime? slotStart) {
    final dateChanged = date != state.selectedDate;
    emit(
      state.copyWith(
        selectedDate: date,
        selectedSlotStart: dateChanged ? null : slotStart,
        clearSelectedDate: date == null,
        clearSelectedSlotStart: dateChanged || slotStart == null,
        clearError: true,
      ),
    );
    if (dateChanged && date != null) {
      fetchAvailability(targetDate: date);
    }
  }

  void updateNotes(Set<String> notes) {
    emit(state.copyWith(bikerNotes: notes, clearError: true));
  }

  void updateSpecialNoteText(String text) {
    emit(state.copyWith(specialNoteText: text, clearError: true));
  }

  void updatePaymentMethod(PaymentMethod method) {
    emit(state.copyWith(paymentMethod: method, clearError: true));
  }

  Future<bool> checkZone(double lat, double lng) async {
    emit(state.copyWith(status: BookingStatus.loading));
    final result = await _bookingRepo.checkZoneAvailability(lat, lng);
    return result.fold(
      (failure) {
        _emitFailure(failure.message);
        return false;
      },
      (data) {
        final isAvailable = data['inServiceArea'] as bool? ?? false;
        final zoneId = data['zoneId'] as String?;
        emit(
          state.copyWith(
            status: BookingStatus.initial,
            selectedAddress: isAvailable
                ? state.selectedAddress?.copyWith(zoneId: zoneId)
                : null,
          ),
        );
        return isAvailable;
      },
    );
  }

  Future<void> fetchAvailability({DateTime? targetDate}) async {
    final date = targetDate ?? state.selectedDate ?? DateTime.now();
    final address = state.selectedAddress;
    final service = state.selectedService;

    if (address == null || service == null) {
      return;
    }

    final requestId = ++_availabilityRequestId;

    final zoneId = await _resolveZoneId(address, requestId);
    if (zoneId == null) return;

    emit(state.copyWith(isAvailabilityLoading: true));

    final result = await _bookingRepo.getAvailability(
      zoneId: zoneId,
      // Wire value — built locale-independently so a ZERODIGIT device locale
      // can never send Arabic-Indic digits as the `date` query parameter.
      date: toWireDate(date),
      packageId: service.id!,
    );
    if (requestId != _availabilityRequestId) return;

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isAvailabilityLoading: false,
            errorMessage: failure.message,
          ),
        );
      },
      (response) {
        emit(
          state.copyWith(
            isAvailabilityLoading: false,
            availabilitySlots: response.slots,
          ),
        );
      },
    );
  }

  /// Returns the zone for [address], looking it up and storing it on the
  /// selected address when unknown. Null means the lookup should stop: it
  /// failed, or a newer one superseded it.
  Future<String?> _resolveZoneId(AddressModel address, int requestId) async {
    final knownZoneId = address.zoneId;
    if (knownZoneId != null && knownZoneId.isNotEmpty) return knownZoneId;

    emit(state.copyWith(isAvailabilityLoading: true));
    final result = await _bookingRepo.checkZoneAvailability(
      address.lat,
      address.lng,
    );
    if (requestId != _availabilityRequestId) return null;

    final (zoneId, zoneFailure) = result.fold(
      (failure) => (null, failure),
      (data) => (data['zoneId'] as String?, null),
    );
    if (zoneId == null) {
      // Surface the backend zone/out-of-area reason; fall back to a localized
      // generic when the failure carries no message.
      final reason = zoneFailure?.message;
      emit(
        state.copyWith(
          isAvailabilityLoading: false,
          errorMessage: (reason != null && reason.isNotEmpty)
              ? reason
              : LocaleKeys.snackbar_default_error.tr(),
        ),
      );
      return null;
    }

    emit(state.copyWith(selectedAddress: address.copyWith(zoneId: zoneId)));
    return zoneId;
  }
}
