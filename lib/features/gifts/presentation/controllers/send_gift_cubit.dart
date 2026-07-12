import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../home/data/repos/services_repository.dart';
import '../../data/repos/gifts_repository.dart';
import '../../../booking/data/repos/booking_repository.dart';
import 'send_gift_state.dart';
import '../../../home/data/models/service_model.dart';
import '../../data/models/gift_theme_model.dart';

class SendGiftCubit extends Cubit<SendGiftState> {
  final GiftsRepository _giftsRepository;
  final ServicesRepository _servicesRepository;
  final BookingRepository _bookingRepository;

  SendGiftCubit({
    required GiftsRepository giftsRepository,
    required ServicesRepository servicesRepository,
    required BookingRepository bookingRepository,
  }) : _giftsRepository = giftsRepository,
       _servicesRepository = servicesRepository,
       _bookingRepository = bookingRepository,
       super(const SendGiftState());


  Future<void> fetchInitialData() async {
    emit(state.copyWith(status: SendGiftStatus.packagesLoading));

    final servicesResult = await _servicesRepository.fetchServices();
    final themesResult = await _giftsRepository.getGiftThemes();

    servicesResult.fold(
      (failure) {
        emit(
          state.copyWith(
            status: SendGiftStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (servicesList) {
        // filter active services
        final activeServices = servicesList
            .where((s) => s.active ?? true)
            .toList();

        themesResult.fold(
          (failure) {
            emit(
              state.copyWith(
                status: SendGiftStatus.failure,
                errorMessage: failure.message,
              ),
            );
          },
          (themesList) {
            // filter active themes, sort by displayOrder
            final activeThemes =
                themesList.where((t) => t.active ?? true).toList()..sort(
                  (a, b) =>
                      (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0),
                );

            emit(
              state.copyWith(
                status: SendGiftStatus.initial,
                services: activeServices,
                themes: activeThemes,
                selectedService: activeServices.isNotEmpty
                    ? activeServices.first
                    : null,
                selectedTheme: activeThemes.isNotEmpty
                    ? activeThemes.first
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  void selectService(ServiceModel service) {
    emit(
      state.copyWith(
        selectedService: service,
        selectedAddonIds: {}, // reset addons when service changes
        clearQuote: true,
      ),
    );
  }

  void toggleAddon(String addonId) {
    final updatedAddons = Set<String>.from(state.selectedAddonIds);
    if (updatedAddons.contains(addonId)) {
      updatedAddons.remove(addonId);
    } else {
      updatedAddons.add(addonId);
    }
    emit(state.copyWith(selectedAddonIds: updatedAddons, clearQuote: true));
  }

  void updateRecipient(String name, String phone) {
    emit(state.copyWith(recipientName: name, recipientPhone: phone));
  }

  void updateCustomization({
    required String message,
    required String deliveryType,
    DateTime? date,
    String? time,
    GiftThemeModel? theme,
  }) {
    emit(
      state.copyWith(
        messageText: message,
        deliveryType: deliveryType,
        scheduledDate: date,
        scheduledTime: time,
        selectedTheme: theme,
      ),
    );
  }

  void updatePaymentMethod(String method) {
    emit(state.copyWith(paymentMethod: method));
  }

  void nextStep() {
    if (state.step < 3) {
      final next = state.step + 1;
      emit(state.copyWith(step: next));
      if (next == 3) {
        fetchQuote();
      }
    }
  }

  Future<void> fetchQuote() async {
    if (state.selectedService == null) return;

    emit(state.copyWith(status: SendGiftStatus.loading));

    final addOnIds = state.selectedAddonIds.toList();
    // Default Riyadh coordinates for the quote estimation
    const double defaultLat = 24.7136;
    const double defaultLng = 46.6753;

    final result = await _bookingRepository.getQuote(
      packageId: state.selectedService!.id!,
      lat: defaultLat,
      lng: defaultLng,
      addOnIds: addOnIds,
      carCount: 1,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: SendGiftStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (quote) {
        emit(
          state.copyWith(
            status: SendGiftStatus.initial,
            quote: quote,
          ),
        );
      },
    );
  }


  void previousStep() {
    if (state.step > 0) {
      emit(state.copyWith(step: state.step - 1));
    }
  }

  Future<void> submitPurchase() async {
    if (state.selectedService == null || state.selectedTheme == null) {
      emit(
        state.copyWith(
          status: SendGiftStatus.failure,
          errorMessage: "Please select a service and a theme.",
        ),
      );
      return;
    }

    emit(state.copyWith(status: SendGiftStatus.loading));

    final giftId = const Uuid().v4();

    // Calculate scheduled ISO string if scheduled delivery is selected
    String? scheduledDeliveryAt;
    if (state.deliveryType == 'SCHEDULED' &&
        state.scheduledDate != null &&
        state.scheduledTime != null) {
      // parse scheduledTime (e.g. "09:00 PM")
      final parts = state.scheduledTime!.split(' ');
      if (parts.length == 2) {
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final isPm = parts[1].toUpperCase() == 'PM';
        if (isPm && hour < 12) {
          hour += 12;
        } else if (!isPm && hour == 12) {
          hour = 0;
        }
        final deliveryDateTime = DateTime(
          state.scheduledDate!.year,
          state.scheduledDate!.month,
          state.scheduledDate!.day,
          hour,
          minute,
        );
        scheduledDeliveryAt = deliveryDateTime.toUtc().toIso8601String();
      }
    }

    final body = {
      'serviceId': state.selectedService!.id,
      'themeId': state.selectedTheme!.id,
      'recipientPhoneE164': '+966${state.recipientPhone}',
      'paymentMethod': state.paymentMethod,
      'recipientName': state.recipientName,
      'messageText': state.messageText,
      if (scheduledDeliveryAt != null)
        'scheduledDeliveryAt': scheduledDeliveryAt,
      if (state.selectedAddonIds.isNotEmpty)
        'addOnIds': state.selectedAddonIds.toList(),
    };

    final result = await _giftsRepository.purchaseGift(
      giftId: giftId,
      data: body,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: SendGiftStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (gift) {
        emit(
          state.copyWith(status: SendGiftStatus.success, purchasedGift: gift),
        );
      },
    );
  }
}
