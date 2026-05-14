import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/custom_button.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../core/route/routes.dart';

class EmptyCarsWidget extends StatelessWidget {
  const EmptyCarsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(AppAssets.emptyCars),
          const SizedBox(height: 40),
          Text(
            LocaleKeys.my_cars_empty_state.tr(),
            style: AppTextStyles.semiBold16,
          ),
          const SizedBox(height: 20),
          Text(
            LocaleKeys.my_cars_empty_desc.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.regular14.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: 30),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: CustomButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.addVehicle);
              },
              text: LocaleKeys.my_cars_add_car.tr(),
              preWidget: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
