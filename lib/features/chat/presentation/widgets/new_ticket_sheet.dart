import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/components/custom_button.dart';
import '../../../../core/components/custom_dropdown_field.dart';
import '../../../../core/components/custom_text_field.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/enums/chat_category_enum.dart';

/// Bottom sheet to open a new support ticket: pick a category + type a subject.
/// Validates (category required, subject required, subject ≤ 200 chars) then
/// invokes [onSubmit] and dismisses.
class NewTicketSheet extends StatefulWidget {
  final void Function(ChatCategory category, String subject) onSubmit;

  const NewTicketSheet({super.key, required this.onSubmit});

  static void show(
    BuildContext context, {
    required void Function(ChatCategory category, String subject) onSubmit,
  }) {
    context.showCustomBottomSheet(child: NewTicketSheet(onSubmit: onSubmit));
  }

  @override
  State<NewTicketSheet> createState() => _NewTicketSheetState();
}

class _NewTicketSheetState extends State<NewTicketSheet> {
  final TextEditingController _subjectController = TextEditingController();
  ChatCategory? _category;
  String? _categoryError;
  String? _subjectError;

  static const int _maxSubject = 200;

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  void _submit() {
    final subject = _subjectController.text.trim();
    setState(() {
      _categoryError = _category == null
          ? LocaleKeys.chat_new_ticket_category_required.tr(context: context)
          : null;
      if (subject.isEmpty) {
        _subjectError = LocaleKeys.chat_new_ticket_subject_required.tr(
          context: context,
        );
      } else if (subject.length > _maxSubject) {
        _subjectError = LocaleKeys.chat_new_ticket_subject_too_long.tr(
          context: context,
        );
      } else {
        _subjectError = null;
      }
    });

    if (_category == null || _subjectError != null) return;

    Navigator.of(context).pop();
    widget.onSubmit(_category!, subject);
  }

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    final labels = ChatCategory.pickerCategories
        .map((c) => c.translationKey.tr(context: context))
        .toList();
    final selectedLabel = _category?.translationKey.tr(context: context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(sw(24))),
        ),
        padding: EdgeInsets.fromLTRB(sw(24), sh(12), sw(24), sh(24)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: sw(40),
                  height: sh(4),
                  decoration: BoxDecoration(
                    color: context.colors.borderSecondary,
                    borderRadius: BorderRadius.circular(sw(4)),
                  ),
                ),
              ),
              SizedBox(height: sh(16)),
              Text(
                LocaleKeys.chat_new_ticket_title.tr(context: context),
                style: AppTextStyles.semiBold16.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              SizedBox(height: sh(16)),
              CustomDropdownField(
                label: LocaleKeys.chat_new_ticket_category.tr(context: context),
                hint: LocaleKeys.chat_new_ticket_category_hint.tr(
                  context: context,
                ),
                value: selectedLabel,
                items: labels,
                isRequired: true,
                onChanged: (label) {
                  final index = labels.indexOf(label ?? '');
                  if (index >= 0) {
                    setState(() {
                      _category = ChatCategory.pickerCategories[index];
                      _categoryError = null;
                    });
                  }
                },
              ),
              if (_categoryError != null) ...[
                SizedBox(height: sh(4)),
                Text(
                  _categoryError!,
                  style: AppTextStyles.regular12.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ],
              SizedBox(height: sh(16)),
              CustomTextField(
                label: LocaleKeys.chat_new_ticket_subject.tr(context: context),
                hint: LocaleKeys.chat_new_ticket_subject_hint.tr(
                  context: context,
                ),
                controller: _subjectController,
                isRequired: true,
                maxLines: 3,
                minLines: 1,
              ),
              if (_subjectError != null) ...[
                SizedBox(height: sh(4)),
                Text(
                  _subjectError!,
                  style: AppTextStyles.regular12.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ],
              SizedBox(height: sh(24)),
              CustomButton(
                text: LocaleKeys.chat_new_ticket_start.tr(context: context),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
