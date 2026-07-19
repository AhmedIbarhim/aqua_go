import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helpers/shimmer_helper.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../address/presentation/controllers/addresses_controller/addresses_cubit.dart';
import '../../../address/presentation/widgets/add_address_bottom_sheet.dart';
import '../controllers/booking_cubit.dart';
import 'location_selection_card.dart';

class SavedLocationsList extends StatefulWidget {
  final int selectedLocationIndex;
  final ValueChanged<int> onAddressSelected;
  final AddressesCubit addressesCubit;

  const SavedLocationsList({
    super.key,
    required this.selectedLocationIndex,
    required this.onAddressSelected,
    required this.addressesCubit,
  });

  @override
  State<SavedLocationsList> createState() => _SavedLocationsListState();
}

class _SavedLocationsListState extends State<SavedLocationsList> {
  bool _hasInitialAddressSelected = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return BlocBuilder<AddressesCubit, AddressesState>(
      bloc: widget.addressesCubit,
      buildWhen: (previous, current) =>
          current is AddressesLoading ||
          current is AddressesLoaded ||
          current is AddressesError ||
          current is AddressesInitial,
      builder: (context, state) {
        if (state is AddressesLoading || state is AddressesInitial) {
          return ShimmerHelper.bookingAddresses(
            selectedAddressIndex: widget.selectedLocationIndex,
            onAddressSelected: widget.onAddressSelected,
          );
        }
        if (state is AddressesLoaded) {
          if (!_hasInitialAddressSelected) {
            _hasInitialAddressSelected = true;
            final bookingAddress = context
                .read<BookingCubit>()
                .state
                .selectedAddress;
            if (bookingAddress != null &&
                bookingAddress.id != 'current_gps' &&
                bookingAddress.id != 'custom_map') {
              final index = state.addresses.indexWhere(
                (a) => a.id == bookingAddress.id,
              );
              if (index != -1) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    widget.onAddressSelected(index + 1);
                  }
                });
              }
            }
          }
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: state.addresses.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final address = state.addresses[index];
              return Padding(
                padding: EdgeInsets.only(bottom: height * 0.01),
                child: LocationSelectionCard(
                  icon: AppAssets.location,
                  title: address.label,
                  subtitle: address.details,
                  isSelected: widget.selectedLocationIndex == index + 1,
                  onTap: () => widget.onAddressSelected(index + 1),
                  onEdit: () {
                    AddAddressBottomSheet.show(
                      context: context,
                      address: address.details,
                      lat: address.lat,
                      lng: address.lng,
                      addressesCubit: widget.addressesCubit,
                      existingAddress: address,
                    );
                  },
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
