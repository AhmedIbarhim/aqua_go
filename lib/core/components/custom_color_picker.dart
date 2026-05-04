import 'package:aqua_go/core/components/custom_bottom_sheet.dart';
import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import '../../generated/locale_keys.g.dart';

class CustomColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const CustomColorPicker({
    super.key,
    this.initialColor = const Color(0xFFF21D4D),
    required this.onColorChanged,
    required this.onSave,
    required this.onCancel,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    Color initialColor = const Color(0xFFD25147),
    required ValueChanged<Color> onColorChanged,
    required VoidCallback onSave,
    required VoidCallback onCancel,
  }) {
    return CustomBottomSheet.show<T>(
      context: context,
      title: LocaleKeys.my_cars_choose_car_color.tr(),
      child: CustomColorPicker(
        initialColor: initialColor,
        onColorChanged: onColorChanged,
        onSave: onSave,
        onCancel: onCancel,
      ),
    );
  }

  @override
  State<CustomColorPicker> createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends State<CustomColorPicker> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
  }

  String _getColorHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  String _getColorName(Color color) {
    // // Mapping some common colors to Arabic names as seen in Figma
    // final int colorVal = color.toARGB32() & 0xFFFFFF;
    // if (colorVal == 0xF21D4D) return "احمر غامق";
    // if (colorVal == 0x000000) return "أسود";
    // if (colorVal == 0xFFFFFFFF) return "أبيض";
    // if (colorVal == 0x808080) return "رمادي";
    // if (colorVal == 0x0000FF) return "أزرق";
    // if (colorVal == 0xFF0000) return "أحمر";
    // if (colorVal == 0x16F7FF) return "سماوي";

    // // Heuristic fallback
    // final double luminance = color.computeLuminance();
    // if (luminance < 0.05) return "أسود";
    // if (luminance > 0.95) return "أبيض";

    return LocaleKeys.my_cars_custom_color.tr();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double pickerSize = (screenWidth / 2).clamp(200.0, 360.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Color Info
        Text(
          _getColorName(_currentColor),
          style: AppTextStyles.medium16.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "HEX: ${_getColorHex(_currentColor)}",
          style: AppTextStyles.regular18.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 32),

        // Color Picker
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ColorPicker(
            color: _currentColor,
            onColorChanged: (color) {
              setState(() {
                _currentColor = color;
              });
              widget.onColorChanged(color);
            },
            wheelDiameter: pickerSize,
            enableOpacity: false,
            wheelSquareBorderRadius: 5000,
            wheelHasBorder: true,
            padding: const EdgeInsets.all(48),
            showColorCode: false,
            showColorName: false,
            showRecentColors: false,
            showColorValue: false,
            enableShadesSelection: false,
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.both: false,
              ColorPickerType.primary: false,
              ColorPickerType.accent: false,
              ColorPickerType.bw: false,
              ColorPickerType.custom: false,
              ColorPickerType.wheel: true,
            },
          ),
        ),
        const SizedBox(height: 48),

        // Action Buttons
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomButton(
                onPressed: widget.onSave,
                text: LocaleKeys.my_cars_save_color.tr(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: CustomButton(
                onPressed: widget.onCancel,
                text: LocaleKeys.cancel.tr(),
                color: Colors.transparent,
                borderColor: context.colors.borderSecondary,
                textColor: context.colors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
