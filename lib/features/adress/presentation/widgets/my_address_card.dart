import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../data/models/address_model.dart';

class MyAddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MyAddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.themeColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.borderSecondary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                address.name,
                style: AppTextStyles.regular16.copyWith(
                  color: context.colors.contentSecondaryLight,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Row(
                      children: [
                        Text(
                          LocaleKeys.edit.tr(),
                          style: AppTextStyles.medium14.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        SvgPicture.asset(
                          AppAssets.edit,
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            context.colors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 16),

                        GestureDetector(
                          onTap: onDelete,
                          child: SvgPicture.asset(
                            AppAssets.remove,
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              context.colors.error,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
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

              const SizedBox(width: 4),

              Text(
                address.formattedAddress,
                textAlign: TextAlign.start,
                style: AppTextStyles.regular14.copyWith(
                  color: context.colors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
