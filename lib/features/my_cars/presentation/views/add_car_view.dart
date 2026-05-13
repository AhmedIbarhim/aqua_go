import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/vehicle_color_picker.dart';
import '../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../core/components/custom_dropdown_field.dart';
import '../../../../core/components/custom_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/my_car_model.dart';
import '../../controllers/my_cars_cubit.dart';
import '../../../../core/utils/app_assets.dart';

class AddCarView extends StatefulWidget {
  final MyCarModel? car;
  const AddCarView({super.key, this.car});

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
    if (widget.car != null) {
      _selectedBrand = widget.car!.name;
      _selectedModel = widget.car!.model;
      _selectedYear = widget.car!.year;
      _selectedColor = Color(widget.car!.colorCode);
      _plateNumberController.text = widget.car!.boardNumber;
    }
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
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: widget.car == null
            ? LocaleKeys.my_cars_add_car_title.tr()
            : LocaleKeys.my_cars_edit_car.tr(),
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
                padding: EdgeInsets.all(width * 0.06),
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
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return BottomActionSheetContainer(
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
                final car = MyCarModel(
                  id: widget.car?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _selectedBrand!,
                  model: _selectedModel!,
                  year: _selectedYear!,
                  image: AppAssets.myCar,
                  typeImage: AppAssets.demoToyota,
                  boardNumber: _plateNumberController.text.trim(),
                  colorCode: _selectedColor!.toARGB32(),
                );
                if (widget.car == null) {
                  context.read<MyCarsCubit>().addCar(car);
                } else {
                  context.read<MyCarsCubit>().updateCar(car);
                }
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: CustomButton(
              onPressed: () => Navigator.pop(context),
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
