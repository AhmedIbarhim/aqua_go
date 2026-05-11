import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/components/custom_text_field.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/enums/gender_enum.dart';
import '../../../../core/extentions/context_extentions.dart';

class ProfileDataView extends StatefulWidget {
  const ProfileDataView({super.key});

  @override
  State<ProfileDataView> createState() => _ProfileDataViewState();
}

class _ProfileDataViewState extends State<ProfileDataView> {
  bool isEditing = false;
  final TextEditingController _nameController = TextEditingController(
    text: 'فيصل محمد',
  );
  final TextEditingController _dobController = TextEditingController(
    text: '1/1/1990',
  );
  GenderEnum _gender = GenderEnum.male;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: isEditing
            ? LocaleKeys.profile_edit_profile_data.tr()
            : LocaleKeys.profile_view_profile.tr(),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CustomTextField(
                      label: LocaleKeys.profile_full_name.tr(),
                      hint: '',
                      controller: _nameController,
                      isRequired: isEditing,
                      enabled: isEditing,
                      fillColor: isEditing
                          ? context.colors.background
                          : context.colors.cardBackGround,
                      style: AppTextStyles.medium16.copyWith(
                        color: isEditing
                            ? context.colors.contentSecondaryLight
                            : context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: LocaleKeys.profile_dob.tr(),
                      hint: '',
                      controller: _dobController,
                      isRequired: false,
                      enabled: isEditing,
                      readOnly: true,
                      onTap: isEditing ? _selectDate : null,
                      prefixIcon: isEditing
                          ? Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgPicture.asset(
                                AppAssets.date,
                                colorFilter: ColorFilter.mode(
                                  context.colors.textPrimary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            )
                          : null,
                      fillColor: isEditing
                          ? context.colors.background
                          : context.colors.cardBackGround,
                      style: AppTextStyles.medium16.copyWith(
                        color: isEditing
                            ? context.colors.contentSecondaryLight
                            : context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildGenderSelection(),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.profile_gender.tr(),
          style: AppTextStyles.medium14.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _GenderCard(
                label: context.isEn
                    ? GenderEnum.male.nameEn()
                    : GenderEnum.male.nameAr(),
                icon: AppAssets.male,
                isSelected: _gender == GenderEnum.male,
                isEditing: isEditing,
                onTap: isEditing
                    ? () => setState(() => _gender = GenderEnum.male)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GenderCard(
                label: context.isEn
                    ? GenderEnum.female.nameEn()
                    : GenderEnum.female.nameAr(),
                icon: AppAssets.female,
                isSelected: _gender == GenderEnum.female,
                isEditing: isEditing,
                onTap: isEditing
                    ? () => setState(() => _gender = GenderEnum.female)
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: context.colors.screenBG,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 24,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: isEditing
          ? Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: LocaleKeys.profile_save_changes.tr(),
                    onPressed: () => setState(() => isEditing = false),
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  flex: 1,
                  child: CustomButton(
                    text: LocaleKeys.cancel.tr(),
                    color: context.colors.background,
                    textColor: context.colors.primary,
                    onPressed: () => setState(() => isEditing = false),
                  ),
                ),
              ],
            )
          : CustomButton(
              text: LocaleKeys.profile_edit_data.tr(),
              postWidget: SvgPicture.asset(
                AppAssets.edit,
                colorFilter: ColorFilter.mode(
                  context.colors.textTheme,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => setState(() => isEditing = true),
            ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final bool isEditing;
  final VoidCallback? onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isEditing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    double iconOpacity;

    if (isEditing) {
      if (isSelected) {
        bgColor = context.colors.brandHover;
        borderColor = context.colors.primary;
        textColor = context.colors.textPrimary;
        iconOpacity = 1.0;
      } else {
        bgColor = context.colors.background;
        borderColor = context.colors.borderSecondary;
        textColor = context.colors.contentSecondaryLight;
        iconOpacity = 1.0;
      }
    } else {
      if (isSelected) {
        bgColor = context.colors.cardBackGround;
        borderColor = context.colors.borderSecondary;
        textColor = context.colors.textSecondary;
        iconOpacity = 1.0;
      } else {
        bgColor = context.colors.background;
        borderColor = context.colors.defaultSubtle;
        textColor = context.colors.contentDisabled;
        iconOpacity = 0.5;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: iconOpacity,
              child: SvgPicture.asset(icon, width: 48, height: 48),
            ),
            const SizedBox(width: 8),

            Text(
              label,
              style: (isSelected && isEditing) || (isSelected && !isEditing)
                  ? AppTextStyles.medium18.copyWith(color: textColor)
                  : AppTextStyles.regular18.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
