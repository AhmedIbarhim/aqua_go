import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/helpers/shimmer_helper.dart';
import '../../data/models/package_model.dart';
import '../../controllers/packages_controller/packages_cubit.dart';
import 'package_card.dart';
import '../views/packages_view.dart';

import 'package:skeletonizer/skeletonizer.dart';

class PackagesListView extends StatelessWidget {
  const PackagesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return BlocBuilder<PackagesCubit, PackagesState>(
      builder: (context, state) {
        final isLoading = state is PackagesLoading || state is PackagesInitial;

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
          return const SizedBox.shrink();
        }

        return Skeletonizer(
          enabled: isLoading,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.home_available_packages.tr(),
                      style: !context.isTablet
                          ? AppTextStyles.bold16
                          : AppTextStyles.bold18,
                    ),
                    GestureDetector(
                      onTap: isLoading
                          ? null
                          : () {
                              context.pushNamed(
                                Routes.packages,
                                arguments: PackagesArgs(
                                  packages: displayPackages,
                                ),
                              );
                            },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            LocaleKeys.home_view_more.tr(),
                            style: AppTextStyles.regular12.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: context.colors.primary,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 10,
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.012),
              SizedBox(
                height: context.isMobile ? width * 0.37 : height * 0.175,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: displayPackages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (context, index) =>
                      PackageCard(packageModel: displayPackages[index]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
