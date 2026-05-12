import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/vehicle_color_picker.dart';
import '../../../../core/components/custom_dropdown_field.dart';
import '../../../../core/components/custom_text_field.dart';

class AddCarView extends StatefulWidget {
  const AddCarView({super.key});

  @override
  State<AddCarView> createState() => _AddCarViewState();
}

class _AddCarViewState extends State<AddCarView> {
  final TextEditingController _plateNumberController = TextEditingController();
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedYear;
  Color? _selectedColor;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _plateNumberController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _selectedBrand != null &&
      _selectedModel != null &&
      _plateNumberController.text.trim().isNotEmpty &&
      _plateNumberController.text.trim().length >= 7 &&
      _plateNumberController.text.trim().length <= 8 &&
      _selectedColor != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.my_cars_add_car_title.tr(),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
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
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomDropdownField(
                        label: LocaleKeys.my_cars_car_brand.tr(),
                        hint: LocaleKeys.select_here.tr(),
                        value: _selectedBrand,
                        onChanged: (val) =>
                            setState(() => _selectedBrand = val),
                        items: const [
                          "تويوتا",
                          "نيسان",
                          "هيونداي",
                          "كيا",
                        ], // Mock data
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      CustomDropdownField(
                        label: LocaleKeys.my_cars_model.tr(),
                        hint: LocaleKeys.select_here.tr(),
                        value: _selectedModel,
                        onChanged: (val) =>
                            setState(() => _selectedModel = val),
                        items: const [
                          "لاند كروزر",
                          "كامري",
                          "إلنترا",
                          "سبورتاج",
                        ], // Mock data
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      VehicleColorPicker(
                        selectedColor: _selectedColor,
                        onColorChanged: (color) =>
                            setState(() => _selectedColor = color),
                      ),
                      const SizedBox(height: 16),
                      CustomDropdownField(
                        label: LocaleKeys.my_cars_manufacturing_year.tr(),
                        hint: LocaleKeys.select_here.tr(),
                        value: _selectedYear,
                        onChanged: (val) => setState(() => _selectedYear = val),
                        items: List.generate(
                          20,
                          (index) => (2024 - index).toString(),
                        ),
                        isRequired: false,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        mustCapitalize: true,
                        label: LocaleKeys.my_cars_plate_number.tr(),
                        hint: LocaleKeys.write_here.tr(),
                        controller: _plateNumberController,
                        isRequired: true,
                      ),
                      const SizedBox(height: 120), // Space for bottom buttons
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActions(),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      color: context.colors.screenBG,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: CustomButton(
              text: LocaleKeys.my_cars_save_car.tr(),
              enabled: _isFormValid,
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: CustomButton(
              onPressed: () {},
              text: LocaleKeys.cancel.tr(),
              color: context.colors.background,
              textColor: context.colors.primary,
              borderColor: context.colors.contentDisabled,
            ),
          ),
        ],
      ),
    );
  }
}
