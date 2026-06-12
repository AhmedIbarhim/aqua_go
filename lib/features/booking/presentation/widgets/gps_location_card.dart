import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../address/controllers/maps_controller/maps_cubit.dart';
import 'location_selection_card.dart';

class GpsLocationCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const GpsLocationCard({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapsCubit, MapsState>(
      builder: (context, state) {
        final hasData = state.selectedAddressName.isNotEmpty;
        return LocationSelectionCard(
          isEnabled: hasData && !state.isLoading,
          icon: AppAssets.gps,
          title: LocaleKeys.address_current_location.tr(),
          subtitle: state.isLoading
              ? '...'
              : state.selectedAddressName.isEmpty
              ? '__'
              : state.selectedAddressName,
          isSelected: isSelected,
          onTap: onTap,
        );
      },
    );
  }
}
