import 'package:aqua_go/core/components/custom_bottom_sheet.dart';
import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/components/custom_text_form_field.dart';
import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

class AddAddressBottomSheet extends StatefulWidget {
  final String address;
  const AddAddressBottomSheet({super.key, required this.address});

  static void show(BuildContext context, String address) {
    CustomBottomSheet.show(
      context: context,
      title: LocaleKeys.address_add_new_location.tr(),
      child: AddAddressBottomSheet(address: address),
    );
  }

  @override
  State<AddAddressBottomSheet> createState() => _AddAddressBottomSheetState();
}

class _AddAddressBottomSheetState extends State<AddAddressBottomSheet> {
  final TextEditingController _addressNameController = TextEditingController();
  final TextEditingController _accessNotesController = TextEditingController();

  @override
  void dispose() {
    _addressNameController.dispose();
    _accessNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          LocaleKeys.address_address_label.tr(),
          isRequired: true,
        ),
        SizedBox(height: height * 0.01),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(width * 0.03),
          decoration: BoxDecoration(
            color: context.colors.background,
            border: Border.all(color: context.colors.borderSecondary),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                AppAssets.location,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  context.colors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),

              SizedBox(
                width: width * 0.7,
                child: Text(
                  widget.address,
                  style: AppTextStyles.medium16.copyWith(
                    color: context.colors.contentSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: height * 0.03),

        _buildSectionLabel(
          LocaleKeys.address_address_name_label.tr(),
          isRequired: true,
        ),
        SizedBox(height: height * 0.01),
        CustomTextFormField(
          controller: _addressNameController,
          label: LocaleKeys.address_address_name_label.tr(),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              AppAssets.location,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                context.colors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        SizedBox(height: height * 0.03),

        _buildSectionLabel(LocaleKeys.address_access_notes_label.tr()),
        SizedBox(height: height * 0.01),
        CustomTextFormField(
          controller: _accessNotesController,
          label: LocaleKeys.address_access_notes_label.tr(),
          keyboardType: TextInputType.multiline,
          minLines: 3,
        ),
        SizedBox(height: height * 0.04),

        CustomButton(
          text: LocaleKeys.address_save_address.tr(),
          onPressed: () {
            // TODO: Implement save logic
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, {bool isRequired = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        if (isRequired)
          Text(
            '*',
            style: AppTextStyles.regular14.copyWith(
              color: context.colors.error,
            ),
          ),
      ],
    );
  }
}
