import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../home/data/repos/services_repository.dart';
import '../../data/repos/gifts_repository.dart';
import 'send_gift_state.dart';
import '../../../home/data/models/service_model.dart';
import '../../data/models/gift_theme_model.dart';
import '../../data/models/purchase_gift_request_model.dart';
import '../../data/models/gift_quote_request_model.dart';
import '../../data/models/gift_payment_init_model.dart';
import '../../data/models/gift_payment_init_request_model.dart';
import '../../../../core/enums/payment_method_enum.dart';

class SendGiftCubit extends Cubit<SendGiftState> {
  final GiftsRepository _giftsRepository;
  final ServicesRepository _servicesRepository;

  SendGiftCubit({
    required GiftsRepository giftsRepository,
    required ServicesRepository servicesRepository,
  }) : _giftsRepository = giftsRepository,
       _servicesRepository = servicesRepository,
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
        status: SendGiftStatus.initial,
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
    emit(
      state.copyWith(
        selectedAddonIds: updatedAddons,
        status: SendGiftStatus.initial,
        clearQuote: true,
      ),
    );
  }

  void updateRecipient(String name, String phone) {
    emit(
      state.copyWith(
        recipientName: name,
        recipientPhone: phone,
        status: SendGiftStatus.initial,
      ),
    );
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
        status: SendGiftStatus.initial,
      ),
    );
  }

  void updatePaymentMethod(PaymentMethod method) {
    emit(state.copyWith(paymentMethod: method, status: SendGiftStatus.initial));
  }

  void nextStep() {
    if (state.step < 3) {
      final next = state.step + 1;
      emit(state.copyWith(step: next, status: SendGiftStatus.initial));
      if (next == 3) {
        fetchQuote();
      }
    }
  }

  void setPromoCode(String? code) {
    emit(state.copyWith(promoCode: code));
    fetchQuote();
  }

  Future<void> fetchQuote() async {
    if (state.selectedService == null) return;

    emit(state.copyWith(status: SendGiftStatus.loading));

    final result = await _giftsRepository.getGiftQuote(
      request: GiftQuoteRequestModel(
        packageId: state.selectedService!.id!,
        pointsToApply: state.pointsToApply,
        promoCode: state.promoCode,
        addOnIds: state.selectedAddonIds.isNotEmpty
            ? state.selectedAddonIds.toList()
            : null,
      ),
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
        emit(state.copyWith(status: SendGiftStatus.initial, quote: quote));
      },
    );
  }

  void previousStep() {
    if (state.step > 0) {
      emit(
        state.copyWith(step: state.step - 1, status: SendGiftStatus.initial),
      );
    }
  }

  Future<GiftPaymentInitModel?> initiateGiftPayment() async {
    if (state.selectedService == null) return null;

    final attemptNonce = const Uuid().v4();
    emit(state.copyWith(
      status: SendGiftStatus.loading,
      attemptNonce: attemptNonce,
    ));

    final result = await _giftsRepository.giftPaymentInit(
      request: GiftPaymentInitRequestModel(
        packageId: state.selectedService!.id!,
        recipientPhone: '+966${state.recipientPhone}',
        pointsToApply: state.pointsToApply,
        promoCode: state.promoCode,
        attemptNonce: attemptNonce,
        addOnIds: state.selectedAddonIds.isNotEmpty
            ? state.selectedAddonIds.toList()
            : null,
      ),
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: SendGiftStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return null;
      },
      (init) {
        emit(state.copyWith(status: SendGiftStatus.initial));
        return init;
      },
    );
  }

  Future<void> submitPurchase({String? moyasarPaymentId}) async {
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

    final request = PurchaseGiftRequestModel(
      packageId: state.selectedService!.id!,
      themeId: state.selectedTheme!.id!,
      recipientPhone: '+966${state.recipientPhone}',
      recipientName: state.recipientName,
      messageText: state.messageText,
      scheduledDeliveryAt: scheduledDeliveryAt,
      pointsToApply: state.pointsToApply,
      moyasarPaymentId: moyasarPaymentId ?? state.moyasarPaymentId,
      promoCode: state.promoCode,
      attemptNonce: state.attemptNonce,
      addOnIds: state.selectedAddonIds.isNotEmpty
          ? state.selectedAddonIds.toList()
          : null,
    );

    final result = await _giftsRepository.purchaseGift(
      giftId: giftId,
      request: request,
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
