import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../data/models/availability_response_model.dart';

class BookingDateTimePicker extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialTime;
  final Function(DateTime) onDateChanged;
  final Function(String) onTimeChanged;
  final List<AvailabilitySlot> availabilitySlots;
  final bool isLoading;

  const BookingDateTimePicker({
    super.key,
    this.initialDate,
    required this.onDateChanged,
    required this.onTimeChanged,
    this.initialTime,
    this.availabilitySlots = const [],
    this.isLoading = false,
  });

  @override
  State<BookingDateTimePicker> createState() => _BookingDateTimePickerState();
}

class _BookingDateTimePickerState extends State<BookingDateTimePicker> {
  DateTime? selectedDate;
  String? selectedTime;
  late List<DateTime> dates;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    selectedTime = widget.initialTime;
    dates = List.generate(
      8,
      (index) => DateTime.now().add(Duration(days: index)),
    );
  }

  @override
  void didUpdateWidget(covariant BookingDateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTime != oldWidget.initialTime) {
      selectedTime = widget.initialTime;
    }
    if (widget.initialDate != oldWidget.initialDate) {
      selectedDate = widget.initialDate;
      selectedTime = null;
    }
  }

  String _formatTimeSlot(DateTime time, BuildContext context) {
    if (context.isAr) {
      final hour = time.hour;
      final minute = time.minute;
      final minStr = minute.toString().padLeft(2, '0');

      String period;
      int displayHour = hour;
      if (hour >= 12) {
        period = hour == 12 ? 'ظهراً' : 'مساءً';
        if (hour > 12) displayHour = hour - 12;
      } else {
        period = 'صباحاً';
        if (hour == 0) displayHour = 12;
      }

      return '$displayHour:$minStr $period';
    } else {
      return DateFormat('h:mm a').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateHeader(),
        SizedBox(height: height * 0.015),
        _buildDateSlider(),
        SizedBox(height: height * 0.015),
        _buildAvailableAppointments(),
      ],
    );
  }

  Widget _buildDateHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text('* ', style: TextStyle(color: Colors.red, fontSize: 16)),
            Text(
              LocaleKeys.bookings_date.tr(),
              style: AppTextStyles.regular16.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              selectedDate != null
                  ? (context.isAr
                        ? DateFormat('MMMM, yyyy', 'ar').format(selectedDate!)
                        : DateFormat('MMMM, yyyy').format(selectedDate!))
                  : LocaleKeys.bookings_choose_day.tr(),
              style: AppTextStyles.medium14.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            SvgPicture.asset(
              AppAssets.date,
              width: 18,
              colorFilter: ColorFilter.mode(
                context.colors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSlider() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height * 0.1,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        separatorBuilder: (context, index) => SizedBox(width: width * 0.02),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected =
              selectedDate != null && DateUtils.isSameDay(date, selectedDate!);
          final dayName = context.isAr
              ? DateFormat('EEEE', 'ar').format(date)
              : DateFormat('EEEE').format(date);
          final dayNumber = DateFormat('d').format(date);

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
                selectedTime = null;
              });
              widget.onDateChanged(date);
            },
            child: Container(
              width: width * 0.16,
              padding: EdgeInsets.symmetric(
                vertical: height * 0.01,
                horizontal: 2,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.brandHover
                    : context.colors.defaultSubtle,
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? Border.all(color: context.colors.primary, width: 1)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: AppTextStyles.regular10.copyWith(
                      color: isSelected
                          ? context.colors.primary
                          : context.colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    dayNumber,
                    style: isSelected
                        ? AppTextStyles.semiBold16.copyWith(
                            color: context.colors.primary,
                          )
                        : AppTextStyles.medium16.copyWith(
                            color: context.colors.textSecondary,
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvailableAppointments() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            LocaleKeys.bookings_available_times.tr(),
            style: AppTextStyles.regular16.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: height * 0.02),
        if (widget.isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CustomLoadingIndicator(size: 70),
            ),
          )
        else if (widget.availabilitySlots.isEmpty ||
            widget.availabilitySlots.every((slot) => !slot.available))
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: Text(
              selectedDate == null
                  ? LocaleKeys.bookings_choose_day.tr()
                  : LocaleKeys.bookings_no_available_times.tr(),
              style: AppTextStyles.regular14.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          )
        else
          Wrap(
            spacing: width * 0.02,
            runSpacing: width * 0.02,
            children: widget.availabilitySlots.map((slot) {
              final timeStr = _formatTimeSlot(slot.start, context);
              final isSelected = selectedTime == timeStr;
              final isDisabled = !slot.available;

              return GestureDetector(
                onTap: isDisabled
                    ? null
                    : () {
                        setState(() {
                          selectedTime = timeStr;
                        });
                        widget.onTimeChanged(timeStr);
                      },
                child: Opacity(
                  opacity: isDisabled ? 0.4 : 1.0,
                  child: Container(
                    width: (width - (width * 0.12 + width * 0.04)) / 3,
                    padding: EdgeInsets.symmetric(vertical: height * 0.015),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.brandHover
                          : (isDisabled
                                ? context.colors.defaultSubtle
                                : context.colors.themeColor),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.borderSecondary,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        timeStr,
                        style: isSelected
                            ? AppTextStyles.medium14.copyWith(
                                color: context.colors.textPrimary,
                              )
                            : AppTextStyles.regular14.copyWith(
                                color: context.colors.textSecondary,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
