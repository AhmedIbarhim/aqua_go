import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/vehicle_color_picker.dart';
import '../widgets/car_brand_dropdown.dart';
import '../widgets/car_model_dropdown.dart';
import '../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/components/custom_dropdown_field.dart';
import '../../../../core/components/custom_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/my_car_model.dart';
import '../../data/models/vehicle_brand_model.dart';
import '../../data/models/vehicle_model_model.dart';
import '../../controllers/my_cars_cubit.dart';

class AddCarView extends StatefulWidget {
  final MyCarModel? car;
  const AddCarView({super.key, this.car});

  @override
  State<AddCarView> createState() => _AddCarViewState();
}

class _AddCarViewState extends State<AddCarView> {
  final TextEditingController _plateNumberController = TextEditingController();
  VehicleBrandModel? _selectedBrandModel;
  VehicleModelModel? _selectedModelModel;
  String? _selectedYear;
  Color? _selectedColor;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      _selectedBrandModel = widget.car!.carBrand;
      _selectedModelModel = widget.car!.carModel;
      _selectedYear = widget.car!.year;
      _selectedColor = Color(widget.car!.colorCode);
      _plateNumberController.text = widget.car!.boardNumber;
    }

    _plateNumberController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<MyCarsCubit>();
      cubit.getBrands();
      if (widget.car != null) {
        cubit.getModels(widget.car!.makeId);
      }
    });
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _selectedBrandModel != null &&
      _selectedModelModel != null &&
      _plateNumberController.text.trim().isNotEmpty &&
      _plateNumberController.text.trim().length >= 7 &&
      _plateNumberController.text.trim().length <= 8 &&
      _selectedColor != null;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return BlocConsumer<MyCarsCubit, MyCarsState>(
      listener: (context, state) {
        if (state is MyCarsActionLoading) {
          context.showLoadingOverlay();
        } else {
          context.hideLoadingOverlay();
        }

        if (state is MyCarsActionSuccess) {
          Navigator.pop(context);
        }

        if (state is MyCarsActionError) {
          context.showWarningAlert(
            title: 'Error',
            message: state.message,
            primaryButtonText: 'OK',
          );
        }
      },
      builder: (context, state) {
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
                          CarBrandDropdown(
                            initialValue: _selectedBrandModel,
                            onChanged: (brand) {
                              setState(() {
                                _selectedBrandModel = brand;
                                _selectedModelModel = null;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          CarModelDropdown(
                            selectedBrand: _selectedBrandModel,
                            initialValue: _selectedModelModel,
                            onChanged: (model) {
                              setState(() {
                                _selectedModelModel = model;
                              });
                            },
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
                            onChanged: (val) =>
                                setState(() => _selectedYear = val),
                            items: List.generate(
                              20,
                              (index) => (2026 - index).toString(),
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
              _buildBottomActions(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomActions(BuildContext context) {
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

                final brandId = _selectedBrandModel?.id ?? widget.car?.makeId;
                final modelId = _selectedModelModel?.id ?? widget.car?.modelId;

                if (brandId == null || modelId == null) {
                  // Fallback safety check
                  context.showWarningAlert(
                    title: 'Error',
                    message: 'Please select a valid brand and model.',
                    primaryButtonText: 'OK',
                  );
                  return;
                }

                // Format Color to ARGB hex string, e.g. "0xFFFFFFFF"
                final colorHex =
                    '0x${_selectedColor!.toARGB32().toRadixString(16).padLeft(8, '0')}';

                final car = MyCarModel(
                  id: widget.car?.id ?? '',
                  makeId: brandId,
                  modelId: modelId,
                  color: colorHex,
                  plateNumber: _plateNumberController.text.trim(),
                );

                if (widget.car == null) {
                  context.read<MyCarsCubit>().addCar(car);
                } else {
                  context.read<MyCarsCubit>().updateCar(car);
                }
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
