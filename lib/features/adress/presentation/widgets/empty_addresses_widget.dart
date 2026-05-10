import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';

class EmptyAddressesWidget extends StatelessWidget {
  const EmptyAddressesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          SvgPicture.asset(AppAssets.noAddresses),
          const SizedBox(height: 40),
          Text(
            LocaleKeys.address_no_addresses.tr(),
            style: AppTextStyles.bold18,
          ),
          const SizedBox(height: 12),
          Text(
            LocaleKeys.address_no_addresses_desc.tr(),
            style: AppTextStyles.regular16.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
