import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/components/custom_text_form_field.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';
import '../controllers/send_gift_cubit.dart';
import '../controllers/send_gift_state.dart';
import 'gift_delivery_card.dart';
import 'gift_theme_cards_grid.dart';
import 'gift_picker_button.dart';

class CustomizeStep extends StatefulWidget {
  const CustomizeStep({super.key});

  @override
  State<CustomizeStep> createState() => _CustomizeStepState();
}

class _CustomizeStepState extends State<CustomizeStep> {
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SendGiftCubit>();
    _messageController = TextEditingController(text: cubit.state.messageText);

    _messageController.addListener(() {
      final state = cubit.state;
      cubit.updateCustomization(
        message: _messageController.text,
        deliveryType: state.deliveryType,
        date: state.scheduledDate,
        time: state.scheduledTime,
        theme: state.selectedTheme,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, SendGiftState state) async {
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    final DateTime lastAllowed = DateTime.now().add(const Duration(days: 10));

    DateTime initial = state.scheduledDate ?? tomorrow;
    if (initial.isBefore(tomorrow)) {
      initial = tomorrow;
    } else if (initial.isAfter(lastAllowed)) {
      initial = lastAllowed;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: tomorrow,
      lastDate: lastAllowed,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: context.colors.primary,
              onPrimary: context.colors.background,
              surface: context.colors.cardBackGround,
              onSurface: context.colors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      context.read<SendGiftCubit>().updateCustomization(
        message: _messageController.text,
        deliveryType: state.deliveryType,
        date: picked,
        time: state.scheduledTime,
        theme: state.selectedTheme,
      );
    }
  }

  Future<void> _selectTime(BuildContext context, SendGiftState state) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: context.colors.primary,
              onPrimary: context.colors.background,
              surface: context.colors.cardBackGround,
              onSurface: context.colors.textPrimary,
            ),
            timePickerTheme: TimePickerThemeData(
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return context.colors.primary;
                }
                return Colors.transparent;
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return context.colors.background;
                }
                return context.colors.textPrimary;
              }),
              dayPeriodBorderSide: BorderSide(color: context.colors.primary),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      final formattedTime = picked.format(context); // e.g. "09:00 PM"
      context.read<SendGiftCubit>().updateCustomization(
        message: _messageController.text,
        deliveryType: state.deliveryType,
        date: state.scheduledDate,
        time: formattedTime,
        theme: state.selectedTheme,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SendGiftCubit, SendGiftState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Recipient Info Title & Message Box ---
            Text(
              context.isAr ? "رسالتك" : "Your Message",
              style: AppTextStyles.bold16.copyWith(
                fontSize: context.sw(16),
                color: context.colors.textPrimary,
              ),
            ),

            SizedBox(height: context.sh(8)),
            CustomTextFormField(
              controller: _messageController,
              label: LocaleKeys.gifts_gift_message_label.tr(context: context),
              hintText: LocaleKeys.gifts_gift_message_hint.tr(context: context),
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              minLines: 3,
            ),

            SizedBox(height: context.sh(24)),

            // --- Delivery Timing Options ---
            Text(
              context.isAr ? "تاريخ ووقت الاهداء" : "Gift Date and Time",
              style: AppTextStyles.bold16.copyWith(
                fontSize: context.sw(16),
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: context.sh(12)),
            GiftDeliveryCard(
              title: context.isAr
                  ? "ارسال الهدية فوراً"
                  : "Send Gift Immediately",
              icon: Icons.send_rounded,
              isSelected: state.deliveryType == 'IMMEDIATE',
              onTap: () {
                context.read<SendGiftCubit>().updateCustomization(
                  message: _messageController.text,
                  deliveryType: 'IMMEDIATE',
                  date: null,
                  time: null,
                  theme: state.selectedTheme,
                );
              },
            ),
            SizedBox(height: context.sh(12)),
            GiftDeliveryCard(
              title: context.isAr ? "جدولة لاحقاً" : "Schedule Later",
              icon: Icons.calendar_today_outlined,
              isSelected: state.deliveryType == 'SCHEDULED',
              onTap: () {
                context.read<SendGiftCubit>().updateCustomization(
                  message: _messageController.text,
                  deliveryType: 'SCHEDULED',
                  date: null,
                  time: null,
                  theme: state.selectedTheme,
                );
              },
            ),

            // Date and Time Pickers (Visible if scheduled)
            if (state.deliveryType == 'SCHEDULED') ...[
              SizedBox(height: context.sh(12)),
              Row(
                children: [
                  Expanded(
                    child: GiftPickerButton(
                      label: state.scheduledDate != null
                          ? DateFormat(
                              'yyyy-MM-dd',
                            ).format(state.scheduledDate!)
                          : (context.isAr ? "اختر تاريخ" : "Choose Date"),
                      icon: AppAssets.calender,
                      onTap: () => _selectDate(context, state),
                    ),
                  ),
                  SizedBox(width: context.sw(12)),

                  Expanded(
                    child: GiftPickerButton(
                      label:
                          state.scheduledTime ??
                          (context.isAr ? "اختر وقت" : "Choose Time"),
                      icon: AppAssets.time,
                      onTap: () => _selectTime(context, state),
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: context.sh(24)),

            // --- Theme Selection Grid ---
            Text(
              context.isAr ? "تصميم البطاقة" : "Card Design",
              style: AppTextStyles.bold16.copyWith(
                fontSize: context.sw(16),
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: context.sh(12)),
            if (state.themes.isEmpty)
              SizedBox(
                height: context.sh(150),
                child: const Center(child: CircularProgressIndicator()),
              )
            else
              GiftThemeCardsGrid(
                themes: state.themes,
                selectedTheme: state.selectedTheme,
                onThemeSelected: (theme) {
                  context.read<SendGiftCubit>().updateCustomization(
                    message: _messageController.text,
                    deliveryType: state.deliveryType,
                    date: state.scheduledDate,
                    time: state.scheduledTime,
                    theme: theme,
                  );
                },
              ),

            SizedBox(height: context.sh(24)),
          ],
        );
      },
    );
  }
}
