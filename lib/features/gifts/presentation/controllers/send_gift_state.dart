import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import '../../../home/data/models/service_model.dart';
import '../../data/models/gift_model.dart';
import '../../data/models/gift_theme_model.dart';
import '../../data/models/gift_quote_model.dart';
import '../../../../core/enums/payment_method_enum.dart';

enum SendGiftStatus {
  initial,
  loading,
  themesLoading,
  packagesLoading,
  success,
  failure,
}

class SendGiftState extends Equatable {
  final int step; // 0: Choose Gift, 1: Recipient, 2: Customize, 3: Review & Pay
  final SendGiftStatus status;
  final String? errorMessage;

  // Catalog Data
  final List<ServiceModel> services;
  final List<GiftThemeModel> themes;

  // Selections
  final ServiceModel? selectedService;
  final Set<String> selectedAddonIds;
  final String recipientName;
  final String recipientPhone; // raw phone input (excluding +966)
  final String messageText;
  final String deliveryType; // 'IMMEDIATE' or 'SCHEDULED'
  final DateTime? scheduledDate;

  /// The picked delivery time, carried structurally from `showTimePicker`.
  ///
  /// This was a display label (`"09:00 PM"`) that the purchase path split on a
  /// space and matched against `'PM'`. In Arabic the picker emits `م`, so the
  /// match failed and every PM delivery was sent 12 hours early; a locale with
  /// its own digits made the hour parse throw outright.
  final TimeOfDay? scheduledTime;
  final GiftThemeModel? selectedTheme;
  final PaymentMethod? paymentMethod;

  // Additional optional payload parameters
  final String? savedCardTokenId;
  final int? pointsToApply;
  final String? moyasarPaymentId;
  final String? promoCode;
  final String? attemptNonce;

  final GiftModel? purchasedGift;
  final GiftQuoteModel? quote;

  const SendGiftState({
    this.step = 0,
    this.status = SendGiftStatus.initial,
    this.errorMessage,
    this.services = const [],
    this.themes = const [],
    this.selectedService,
    this.selectedAddonIds = const {},
    this.recipientName = '',
    this.recipientPhone = '',
    this.messageText = '',
    this.deliveryType = 'IMMEDIATE',
    this.scheduledDate,
    this.scheduledTime,
    this.selectedTheme,
    this.paymentMethod,
    this.savedCardTokenId,
    this.pointsToApply,
    this.moyasarPaymentId,
    this.promoCode,
    this.attemptNonce,
    this.purchasedGift,
    this.quote,
  });

  SendGiftState copyWith({
    int? step,
    SendGiftStatus? status,
    String? errorMessage,
    List<ServiceModel>? services,
    List<GiftThemeModel>? themes,
    ServiceModel? selectedService,
    Set<String>? selectedAddonIds,
    String? recipientName,
    String? recipientPhone,
    String? messageText,
    String? deliveryType,
    DateTime? scheduledDate,
    TimeOfDay? scheduledTime,
    GiftThemeModel? selectedTheme,
    PaymentMethod? paymentMethod,
    String? savedCardTokenId,
    int? pointsToApply,
    String? moyasarPaymentId,
    String? promoCode,
    String? attemptNonce,
    GiftModel? purchasedGift,
    GiftQuoteModel? quote,
    bool clearService = false,
    bool clearTheme = false,
    bool clearQuote = false,
  }) {
    return SendGiftState(
      step: step ?? this.step,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      services: services ?? this.services,
      themes: themes ?? this.themes,
      selectedService: clearService
          ? null
          : (selectedService ?? this.selectedService),
      selectedAddonIds: selectedAddonIds ?? this.selectedAddonIds,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      messageText: messageText ?? this.messageText,
      deliveryType: deliveryType ?? this.deliveryType,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      selectedTheme: clearTheme ? null : (selectedTheme ?? this.selectedTheme),
      paymentMethod: paymentMethod ?? this.paymentMethod,
      savedCardTokenId: savedCardTokenId ?? this.savedCardTokenId,
      pointsToApply: pointsToApply ?? this.pointsToApply,
      moyasarPaymentId: moyasarPaymentId ?? this.moyasarPaymentId,
      promoCode: promoCode ?? this.promoCode,
      attemptNonce: attemptNonce ?? this.attemptNonce,
      purchasedGift: purchasedGift ?? this.purchasedGift,
      quote: clearQuote ? null : (quote ?? this.quote),
    );
  }

  /// The scheduled delivery as a single wall clock, or null until BOTH pickers
  /// have been used. Feeds `scheduledDeliveryAt`; the picked fields are carried
  /// through verbatim, so nothing between the picker and the wire re-reads a
  /// formatted string.
  DateTime? get scheduledDeliveryAt {
    final date = scheduledDate;
    final time = scheduledTime;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  List<Object?> get props => [
    step,
    status,
    errorMessage,
    services,
    themes,
    selectedService,
    selectedAddonIds,
    recipientName,
    recipientPhone,
    messageText,
    deliveryType,
    scheduledDate,
    scheduledTime,
    selectedTheme,
    paymentMethod,
    savedCardTokenId,
    pointsToApply,
    moyasarPaymentId,
    promoCode,
    attemptNonce,
    purchasedGift,
    quote,
  ];
}
