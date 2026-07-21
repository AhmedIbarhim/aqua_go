import 'package:aqua_go/features/home/data/models/offer_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/offer_card.dart';

class OffersArgs {
  final List<OfferModel> offers;
  OffersArgs({required this.offers});
}

class OffersView extends StatelessWidget {
  const OffersView({super.key, required this.offers});

  final List<OfferModel> offers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GenericAppBar(
        title: LocaleKeys.home_available_offers.tr(context: context),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: offers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) => GestureDetector(
            onTap: () => _handleOfferTap(context, offers[index]),
            child: OfferCard(offerModel: offers[index], atHome: false),
          ),
        ),
      ),
    );
  }

  Future<void> _handleOfferTap(BuildContext context, OfferModel banner) async {
    switch (banner.ctaType) {
      case 'URL':
        final target = banner.ctaTarget;
        if (target == null || target.isEmpty) return;
        try {
          final ok = await launchUrl(
            Uri.parse(target),
            mode: LaunchMode.externalApplication,
          );
          if (!ok && context.mounted) {
            context.showWarningSnackBar(
              context.isAr ? 'تعذّر فتح الرابط.' : 'Could not open the link.',
            );
          }
        } catch (_) {
          if (context.mounted) {
            context.showWarningSnackBar(
              context.isAr ? 'تعذّر فتح الرابط.' : 'Could not open the link.',
            );
          }
        }
        break;
      case 'DEEPLINK':
        switch (banner.ctaTarget) {
          case 'packages':
            Navigator.pushNamed(context, Routes.packages);
            break;
          default:
            // Unknown deeplink target — safe no-op.
            break;
        }
        break;
      default:
        // 'NONE' / null / unknown — no-op.
        break;
    }
  }
}
