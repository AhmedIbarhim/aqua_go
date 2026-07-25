import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/error_retry_widget.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/helpers/shimmer_helper.dart';
import '../../../../generated/locale_keys.g.dart';
import '../controllers/package_detail_controller/package_detail_cubit.dart';
import '../widgets/package_card.dart';

/// Single-package screen reached from a PACKAGE offer (home rail or the offer
/// detail screen). [PackageCard] already owns the subscribe tap (guest prompt +
/// subscription bottom sheet), so this screen only resolves the id and renders
/// the card.
class PackageDetailView extends StatelessWidget {
  const PackageDetailView({super.key, required this.packageId});

  final String packageId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GenericAppBar(
        title: LocaleKeys.booking_package_package_details.tr(context: context),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BlocBuilder<PackageDetailCubit, PackageDetailState>(
          builder: (context, state) {
            if (state is PackageDetailInitial || state is PackageDetailLoading) {
              return ShimmerHelper.packagesList(itemCount: 1);
            }

            if (state is PackageDetailNotFound) {
              return ErrorRetryWidget(
                errorMessage: context.isAr
                    ? 'الباقة غير متاحة الآن.'
                    : 'This package is no longer available.',
                onRetry: () =>
                    context.read<PackageDetailCubit>().getPackage(packageId),
              );
            }

            if (state is PackageDetailError) {
              return ErrorRetryWidget(
                errorMessage: state.message,
                onRetry: () =>
                    context.read<PackageDetailCubit>().getPackage(packageId),
              );
            }

            final package = (state as PackageDetailLoaded).package;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [PackageCard(packageModel: package, atHome: false)],
            );
          },
        ),
      ),
    );
  }
}
