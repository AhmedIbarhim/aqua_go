import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/custom_button.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../core/route/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/my_cars_cubit.dart';

class EmptyCarsWidget extends StatelessWidget {
  const EmptyCarsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: SvgPicture.asset(
              context.isDarkTheme
                  ? AppAssets.emptyCarsDark
                  : AppAssets.emptyCarsLight,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            LocaleKeys.my_cars_empty_state.tr(context: context),
            style: AppTextStyles.semiBold16,
          ),
          const SizedBox(height: 20),
          Text(
            LocaleKeys.my_cars_empty_desc.tr(context: context),
            textAlign: TextAlign.center,
            style: AppTextStyles.regular14.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: 30),
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.6,
            child: CustomButton(
              onPressed: () {
                context.pushNamed(Routes.addVehicle).then((val) {
                  if (val == true && context.mounted) {
                    context.read<MyCarsCubit>().getCars();
                  }
                });
              },
              text: LocaleKeys.my_cars_add_car.tr(context: context),
              preWidget: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
