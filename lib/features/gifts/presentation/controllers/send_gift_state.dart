import 'package:equatable/equatable.dart';
import '../../../home/data/models/service_model.dart';
import '../../data/models/gift_model.dart';
import '../../data/models/gift_theme_model.dart';
import '../../../booking/data/models/quote_model.dart';

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
  final String? scheduledTime; // e.g. "09:00 PM"
  final GiftThemeModel? selectedTheme;
  final String paymentMethod; // 'APPLE_PAY' or 'CREDIT_CARD'

  final GiftModel? purchasedGift;
  final QuoteModel? quote;

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
    this.paymentMethod = 'APPLE_PAY',
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
    String? scheduledTime,
    GiftThemeModel? selectedTheme,
    String? paymentMethod,
    GiftModel? purchasedGift,
    QuoteModel? quote,
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
      purchasedGift: purchasedGift ?? this.purchasedGift,
      quote: clearQuote ? null : (quote ?? this.quote),
    );
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
    purchasedGift,
    quote,
  ];
}

