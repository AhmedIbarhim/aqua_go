import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';

class BookingDateTimePicker extends StatefulWidget {
  final DateTime initialDate;
  final String? initialTime;
  final Function(DateTime) onDateChanged;
  final Function(String) onTimeChanged;

  const BookingDateTimePicker({
    super.key,
    required this.initialDate,
    required this.onDateChanged,
    required this.onTimeChanged,
    this.initialTime,
  });

  @override
  State<BookingDateTimePicker> createState() => _BookingDateTimePickerState();
}

class _BookingDateTimePickerState extends State<BookingDateTimePicker> {
  late DateTime selectedDate;
  String? selectedTime;

  final List<String> availableTimes = [
    '9:00 صباحاً',
    '9:30 صباحاً',
    '10:00 صباحاً',
    '10:30 صباحاً',
    '11:00 صباحاً',
    '11:30 صباحاً',
    '12:00 ظهراً',
    '12:30 ظهراً',
    '1:00 ظهراً',
  ];

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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateHeader(),
        const SizedBox(height: 12),
        _buildDateSlider(),
        const SizedBox(height: 12),
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
              context.isAr
                  ? DateFormat('MMMM, yyyy', 'ar').format(selectedDate)
                  : DateFormat('MMMM, yyyy').format(selectedDate),
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
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.09,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = DateUtils.isSameDay(date, selectedDate);
          final dayName = context.isAr
              ? DateFormat('EEEE', 'ar').format(date)
              : DateFormat('EEEE').format(date);
          final dayNumber = DateFormat('d').format(date);

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
              widget.onDateChanged(date);
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.15,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
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
                  const SizedBox(height: 8),
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
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTimes.map((time) {
            final isSelected = selectedTime == time;
            // Mocking some disabled times for design consistency
            final isDisabled = time.contains('1:00');

            return GestureDetector(
              onTap: isDisabled
                  ? null
                  : () {
                      setState(() {
                        selectedTime = time;
                      });
                      widget.onTimeChanged(time);
                    },
              child: Container(
                width: (MediaQuery.of(context).size.width - 64) / 3,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.brandHover
                      : context.colors.themeColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.borderSecondary,
                  ),
                ),
                child: Center(
                  child: Text(
                    time,
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
            );
          }).toList(),
        ),
      ],
    );
  }
}
