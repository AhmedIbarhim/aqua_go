import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../core/utils/date_time_formatter.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../data/models/availability_response_model.dart';

class BookingDateTimePicker extends StatefulWidget {
  final DateTime? initialDate;

  final DateTime? initialSlotStart;
  final Function(DateTime) onDateChanged;

  final Function(DateTime) onSlotSelected;
  final List<AvailabilitySlot> availabilitySlots;
  final bool isLoading;

  const BookingDateTimePicker({
    super.key,
    this.initialDate,
    required this.onDateChanged,
    required this.onSlotSelected,
    this.initialSlotStart,
    this.availabilitySlots = const [],
    this.isLoading = false,
  });

  @override
  State<BookingDateTimePicker> createState() => _BookingDateTimePickerState();
}

class _BookingDateTimePickerState extends State<BookingDateTimePicker> {
  DateTime? selectedDate;
  DateTime? selectedSlotStart;
  late List<DateTime> dates;

  static const int _bookableDayCount = 7;

  List<DateTime> _generateDates(DateTime? initialDate) {
    final today = DateUtils.dateOnly(DateTime.now());
    return List.generate(
      _bookableDayCount,
      (index) => today.add(Duration(days: index)),
    );
  }

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    selectedSlotStart = widget.initialSlotStart;
    dates = _generateDates(selectedDate);
  }

  @override
  void didUpdateWidget(covariant BookingDateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSlotStart != oldWidget.initialSlotStart) {
      selectedSlotStart = widget.initialSlotStart;
    }
    if (widget.initialDate != oldWidget.initialDate) {
      selectedDate = widget.initialDate;
      selectedSlotStart = null;
      dates = _generateDates(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
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
              LocaleKeys.bookings_date.tr(context: context),
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
                  ? formatMonthYear(selectedDate!)
                  : LocaleKeys.bookings_choose_day.tr(context: context),
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
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
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
          final dayName = formatWeekday(date);
          final dayNumber = formatDayOfMonth(date);

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
                selectedSlotStart = null;
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
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            LocaleKeys.bookings_available_times.tr(context: context),
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
                  ? LocaleKeys.bookings_choose_day.tr(context: context)
                  : LocaleKeys.bookings_no_available_times.tr(context: context),
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
              final timeStr = formatClockTime(slot.start);
              // Matched on the slot's instant, not on its label: the label is
              // display-only and is not stable across locales.
              final isSelected =
                  selectedSlotStart != null &&
                  selectedSlotStart!.isAtSameMomentAs(slot.start);
              final isDisabled = !slot.available;

              return GestureDetector(
                onTap: isDisabled
                    ? null
                    : () {
                        setState(() {
                          selectedSlotStart = slot.start;
                        });
                        widget.onSlotSelected(slot.start);
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
