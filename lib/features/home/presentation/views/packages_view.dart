import 'package:aqua_go/features/home/data/models/package_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/helpers/shimmer_helper.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/package_card.dart';
import '../controllers/packages_controller/packages_cubit.dart';

class PackagesView extends StatelessWidget {
  const PackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GenericAppBar(title: LocaleKeys.home_available_packages.tr()),
      body: Container(
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BlocBuilder<PackagesCubit, PackagesState>(
          builder: (context, state) {
            final isLoading =
                state is PackagesLoading || state is PackagesInitial;

            if (state is PackagesError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    state.message,
                    style: AppTextStyles.regular12.copyWith(
                      color: context.colors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final List<PackageModel> displayPackages;
            if (isLoading) {
              displayPackages = ShimmerHelper.getDummyPackages();
            } else if (state is PackagesLoaded) {
              displayPackages = state.packages;
            } else {
              displayPackages = [];
            }

            if (!isLoading && displayPackages.isEmpty) {
              return Center(
                child: Text(
                  LocaleKeys.home_available_packages.tr(),
                  style: AppTextStyles.regular14,
                ),
              );
            }

            return Skeletonizer(
              enabled: isLoading,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: displayPackages.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 24),
                itemBuilder: (context, index) => PackageCard(
                  packageModel: displayPackages[index],
                  atHome: false,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
