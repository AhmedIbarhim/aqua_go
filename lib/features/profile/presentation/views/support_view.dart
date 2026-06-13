import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/utils/app_assets.dart';

import '../widgets/profile_tile.dart';
import '../../../../core/route/routes.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.support_title.tr(),
        centerTitle: false,
      ),
      body: Column(
        children: [
          SizedBox(height: sh(16)),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sw(24)),
                  topRight: Radius.circular(sw(24)),
                ),
              ),
              padding: EdgeInsets.all(sw(24)),
              child: Column(
                children: [
                  ProfileTile(
                    title: LocaleKeys.support_faq.tr(),
                    icon: AppAssets.question,
                    onTap: () {
                      context.pushNamed(Routes.faqs);
                    },
                  ),
                  SizedBox(height: sh(12)),
                  ProfileTile(
                    title: LocaleKeys.support_complaint_log.tr(),
                    icon: AppAssets.documentCopy,
                    onTap: () {
                      context.pushNamed(Routes.complainsRecord);
                    },
                  ),
                  SizedBox(height: sh(12)),
                  // ProfileTile(
                  //   title: LocaleKeys.support_whatsapp_contact.tr(),
                  //   icon: AppAssets.whatsapp,
                  //   alreadyColoredIcon: true,
                  //   onTap: () {
                  //     // TODO: Open WhatsApp link
                  //   },
                  //   textColor: context.colors.success,
                  //   borderColor: context.colors.success,
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
