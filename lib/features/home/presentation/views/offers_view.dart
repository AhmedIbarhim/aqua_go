import 'package:aqua_go/features/home/presentation/data/models/offer_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/offer_card.dart';

class OffersView extends StatelessWidget {
  const OffersView({super.key, required this.offers});

  final List<OfferModel> offers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GenericAppBar(title: LocaleKeys.home_available_offers.tr()),
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
          itemBuilder: (context, index) =>
              OfferCard(offerModel: offers[index], atHome: false),
        ),
      ),
    );
  }
}
