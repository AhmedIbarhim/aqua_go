import 'package:aqua_go/features/home/presentation/data/models/package_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/package_card.dart';

class PackagesArgs {
  final List<PackageModel> packages;
  PackagesArgs({required this.packages});
}

class PackagesView extends StatelessWidget {
  const PackagesView({super.key, required this.packages});

  final List<PackageModel> packages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GenericAppBar(title: LocaleKeys.home_available_packages.tr()),
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
          itemCount: packages.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) =>
              PackageCard(packageModel: packages[index], atHome: false),
        ),
      ),
    );
  }
}
