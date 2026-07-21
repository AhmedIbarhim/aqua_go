import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/utils/app_assets.dart';

import '../widgets/profile_tile.dart';
import '../../../../core/route/routes.dart';
import '../controllers/support_cubit/support_cubit.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);
    double sh(double height) => context.sh(height);

    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.support_title.tr(context: context),
        centerTitle: false,
      ),
      body: BlocListener<SupportCubit, SupportState>(
        listener: (context, state) async {
          if (state is SupportLoading) {
            context.showLoadingOverlay();
          } else {
            context.hideLoadingOverlay();
          }

          if (state is SupportFailure) {
            context.showErrorSnackBar(state.message);
          } else if (state is SupportWhatsAppLoaded) {
            final whatsappUrl = Uri.parse(
              'https://wa.me/${state.whatsappNumber}',
            );
            try {
              if (await canLaunchUrl(whatsappUrl)) {
                await launchUrl(
                  whatsappUrl,
                  mode: LaunchMode.externalApplication,
                );
              } else {
                context.showErrorSnackBar('Could not launch WhatsApp');
              }
            } catch (e) {
              context.showErrorSnackBar('Could not launch WhatsApp: $e');
            }
          }
        },
        child: Column(
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
                      title: LocaleKeys.support_faq.tr(context: context),
                      icon: AppAssets.question,
                      onTap: () {
                        context.pushNamed(Routes.faqs);
                      },
                    ),
                    SizedBox(height: sh(12)),
                    ProfileTile(
                      title: LocaleKeys.support_complaint_log.tr(
                        context: context,
                      ),
                      icon: AppAssets.documentCopy,
                      onTap: () {
                        context.pushNamed(Routes.complainsRecord);
                      },
                    ),
                    SizedBox(height: sh(12)),
                    ProfileTile(
                      title: LocaleKeys.support_contact_us.tr(context: context),
                      icon: AppAssets.messages,
                      onTap: () {
                        context.pushNamed(Routes.chatInbox);
                      },
                    ),
                    SizedBox(height: sh(12)),
                    ProfileTile(
                      title: LocaleKeys.support_whatsapp_contact.tr(
                        context: context,
                      ),
                      icon: AppAssets.whatsapp,
                      alreadyColoredIcon: true,
                      onTap: () {
                        context.read<SupportCubit>().getWhatsAppNumber();
                      },
                      textColor: context.colors.success,
                      borderColor: context.colors.success,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
