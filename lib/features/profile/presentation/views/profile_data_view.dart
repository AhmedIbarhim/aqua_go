import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/components/custom_text_field.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/enums/gender_enum.dart';
import '../../../../core/route/routes.dart';
import '../widgets/gender_selection_widget.dart';

import 'package:aqua_go/features/auth/data/repos/auth_repo.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';

class ProfileDataView extends StatefulWidget {
  final bool isFirstTime;
  const ProfileDataView({super.key, this.isFirstTime = false});

  @override
  State<ProfileDataView> createState() => _ProfileDataViewState();
}

class _ProfileDataViewState extends State<ProfileDataView> {
  late bool isEditing;
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  Gender _gender = Gender.male;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    isEditing = widget.isFirstTime;
    final user = locator<AuthRepo>().getUser();
    _nameController = TextEditingController(
      text: widget.isFirstTime ? '' : user?.name ?? '',
    );
    _birthDate = user?.birthdate;
    _dobController = TextEditingController(
      text: widget.isFirstTime
          ? ''
          : (user?.birthdate != null
                ? '${user!.birthdate!.day}/${user.birthdate!.month}/${user.birthdate!.year}'
                : ''),
    );
    if (!widget.isFirstTime && user?.gender != null) {
      _gender = GenderEnumExtension.fromString(user?.gender);
    }
  }

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
                    GenderSelectionWidget(
                      selectedGender: _gender,
                      isEditing: isEditing,
                      onChanged: (value) => setState(() => _gender = value),
                    ),
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
        _birthDate = picked;
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
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
      child: widget.isFirstTime
          ? CustomButton(
              text: LocaleKeys.proceed.tr(),
              onPressed: () async {
                final user = locator<AuthRepo>().getUser();
                if (user != null) {
                  final updatedUser = user.copyWith(
                    name: _nameController.text,
                    gender: _gender.name,
                    birthdate: _birthDate,
                  );
                  await locator<AuthRepo>().saveUser(updatedUser);
                }
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.layout,
                    (route) => false,
                  );
                }
              },
            )
          : isEditing
          ? Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: LocaleKeys.profile_save_changes.tr(),
                    onPressed: () async {
                      final user = locator<AuthRepo>().getUser();
                      if (user != null) {
                        final updatedUser = user.copyWith(
                          name: _nameController.text,
                          gender: _gender.name,
                          birthdate: _birthDate,
                        );
                        await locator<AuthRepo>().saveUser(updatedUser);
                      }
                      setState(() => isEditing = false);
                    },
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
