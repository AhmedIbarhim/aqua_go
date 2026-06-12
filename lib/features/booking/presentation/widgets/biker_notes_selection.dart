import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';

class BikerNotesSelection extends StatefulWidget {
  final Set<String>? initialNotes;
  final String? initialSpecialNoteText;
  final Function(Set<String>) onNotesChanged;
  final Function(String)? onSpecialNoteTextChanged;

  const BikerNotesSelection({
    super.key,
    this.initialNotes,
    this.initialSpecialNoteText,
    required this.onNotesChanged,
    this.onSpecialNoteTextChanged,
  });

  @override
  State<BikerNotesSelection> createState() => _BikerNotesSelectionState();
}

class _BikerNotesSelectionState extends State<BikerNotesSelection> {
  final Set<String> selectedNotes = {};
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    if (widget.initialNotes != null) {
      selectedNotes.addAll(widget.initialNotes!);
    }
    _noteController = TextEditingController(
      text: widget.initialSpecialNoteText,
    );
  }

  @override
  void didUpdateWidget(covariant BikerNotesSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialNotes != oldWidget.initialNotes) {
      setState(() {
        selectedNotes.clear();
        if (widget.initialNotes != null) {
          selectedNotes.addAll(widget.initialNotes!);
        }
      });
    }
    if (widget.initialSpecialNoteText != oldWidget.initialSpecialNoteText &&
        widget.initialSpecialNoteText != _noteController.text) {
      _noteController.text = widget.initialSpecialNoteText ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> notes = [
    {'key': LocaleKeys.bookings_special_note, 'icon': AppAssets.adding},
    {'key': LocaleKeys.bookings_dont_call, 'icon': AppAssets.noCalls},
    {'key': LocaleKeys.bookings_outside_only, 'icon': AppAssets.myCarsDisabled},
  ];

  @override
  Widget build(BuildContext context) {
    final showTextField = selectedNotes.contains(
      LocaleKeys.bookings_special_note,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: notes.map((note) {
              final isSelected = selectedNotes.contains(note['key']);
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedNotes.contains(note['key'])) {
                        selectedNotes.remove(note['key']);
                      } else {
                        selectedNotes.add(note['key']);
                      }
                      widget.onNotesChanged(selectedNotes);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
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
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          note['icon'],
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            isSelected
                                ? context.colors.primary
                                : context.colors.textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          (note['key'] as String).tr(),
                          style: AppTextStyles.regular14.copyWith(
                            color: isSelected
                                ? context.colors.textPrimary
                                : context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (showTextField) ...[
          const SizedBox(height: 16),
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colors.themeColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.colors.borderSecondary),
            ),
            child: TextField(
              controller: _noteController,
              maxLines: null,
              expands: true,
              textAlign: TextAlign.right,
              onChanged: widget.onSpecialNoteTextChanged,
              style: AppTextStyles.medium16.copyWith(
                color: context.colors.contentSecondaryLight,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
