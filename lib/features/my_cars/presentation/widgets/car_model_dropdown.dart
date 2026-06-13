import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/components/custom_bottom_sheet.dart';
import '../../../../core/components/custom_loading_indicator.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/vehicle_make_model.dart';
import '../../data/models/vehicle_model_model.dart';
import '../controllers/my_cars_cubit.dart';

class CarModelDropdown extends StatefulWidget {
  final VehicleMakeModel? selectedBrand;
  final VehicleModelModel? initialValue;
  final ValueChanged<VehicleModelModel?> onChanged;

  const CarModelDropdown({
    super.key,
    this.selectedBrand,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<CarModelDropdown> createState() => _CarModelDropdownState();
}

class _CarModelDropdownState extends State<CarModelDropdown> {
  VehicleModelModel? _selectedValue;
  List<VehicleModelModel> _models = [];

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    if (_selectedValue != null) {
      _models = [_selectedValue!];
    }
  }

  @override
  void didUpdateWidget(covariant CarModelDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedBrand != oldWidget.selectedBrand) {
      setState(() {
        _selectedValue = null;
        _models = [];
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onChanged(null);
        }
      });
      if (widget.selectedBrand != null) {
        context.read<MyCarsCubit>().getModels(widget.selectedBrand!.id);
      }
    } else if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _selectedValue = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyCarsCubit, MyCarsState>(
      buildWhen: (prev, current) =>
          current is ModelsLoaded || current is ModelsLoading,
      builder: (context, state) {
        if (state is ModelsLoaded) {
          _models = state.models;
        } else if (state is ModelsLoading) {
          _models = [];
        }

        final isArabic = context.locale.languageCode == 'ar';
        final currentDisplayValue = _selectedValue != null
            ? (isArabic
                  ? _selectedValue!.vehicleModelName.nameAr
                  : _selectedValue!.vehicleModelName.nameEn)
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "* ",
                  style: AppTextStyles.regular14.copyWith(
                    color: context.colors.error,
                  ),
                ),
                Text(
                  LocaleKeys.my_cars_model.tr(),
                  style: AppTextStyles.medium14.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: widget.selectedBrand == null
                  ? null
                  : () {
                      final myCarsCubit = context.read<MyCarsCubit>();
                      CustomBottomSheet.show(
                        context: context,
                        title: LocaleKeys.my_cars_model.tr(),
                        child: BlocProvider<MyCarsCubit>.value(
                          value: myCarsCubit,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.65,
                            ),
                            child: BlocBuilder<MyCarsCubit, MyCarsState>(
                              builder: (context, sheetState) {
                                final currentModels = sheetState is ModelsLoaded
                                    ? sheetState.models
                                    : _models;

                                if (sheetState is ModelsLoading ||
                                    currentModels.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 32,
                                      ),
                                      child: CustomLoadingIndicator(size: 80),
                                    ),
                                  );
                                }

                                return SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: currentModels.map((item) {
                                      final displayName = isArabic
                                          ? item.vehicleModelName.nameAr
                                          : item.vehicleModelName.nameEn;
                                      final isSelected =
                                          item.id == _selectedValue?.id;
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedValue = item;
                                          });
                                          widget.onChanged(item);
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: context
                                                    .colors
                                                    .borderSecondary
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                displayName,
                                                style: AppTextStyles.medium16
                                                    .copyWith(
                                                      color: isSelected
                                                          ? context
                                                                .colors
                                                                .primary
                                                          : context
                                                                .colors
                                                                .textPrimary,
                                                    ),
                                              ),
                                              if (isSelected)
                                                Icon(
                                                  Icons.check_circle,
                                                  color: context.colors.primary,
                                                  size: 20,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: MediaQuery.of(context).size.height * 0.012,
                ),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  border: Border.all(color: context.colors.borderSecondary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        currentDisplayValue ?? LocaleKeys.select_here.tr(),
                        style: AppTextStyles.regular14.copyWith(
                          color: currentDisplayValue == null
                              ? context.colors.contentDisabled
                              : context.colors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: context.colors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
