import 'package:aqua_go/core/components/custom_radio_widget.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import '../../../../generated/locale_keys.g.dart';

class ComplaintTypes extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String> onSelected;

  const ComplaintTypes({
    super.key,
    this.initialValue,
    required this.onSelected,
  });

  @override
  State<ComplaintTypes> createState() => _ComplaintTypesState();
}

class _ComplaintTypesState extends State<ComplaintTypes> {
  late String? _selectedValue;

  final List<String> _types = [
    LocaleKeys.bookings_complaint_types_poor_wash_quality.tr(),
    LocaleKeys.bookings_complaint_types_arrival_delay.tr(),
    LocaleKeys.bookings_complaint_types_worker_behavior.tr(),
    LocaleKeys.bookings_complaint_types_car_damage.tr(),
    LocaleKeys.bookings_complaint_types_wrong_service.tr(),
    LocaleKeys.bookings_complaint_types_billing_issue.tr(),
    LocaleKeys.bookings_complaint_types_safety_incident.tr(),
    LocaleKeys.bookings_complaint_types_other_type.tr(),
  ];

  @override
  void initState() {
    super.initState();
    try {
      _selectedValue = _types.firstWhere((type) => type == widget.initialValue);
    } catch (_) {
      _selectedValue = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _types
          .map(
            (type) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedValue = type;
                  });
                  widget.onSelected(type);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.themeColor,
                    border: Border.all(
                      color: _selectedValue == type
                          ? context.colors.primary
                          : context.colors.borderSecondary,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          type.tr(),
                          style: AppTextStyles.medium14.copyWith(
                            color: context.colors.textPrimary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      CustomRadioWidget(isSelected: _selectedValue == type),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
