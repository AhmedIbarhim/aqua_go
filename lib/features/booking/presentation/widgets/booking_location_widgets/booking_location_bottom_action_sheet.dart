import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/extentions/context_extentions.dart';
import '../../../../../core/route/routes.dart';
import '../../../../../core/route/app_router.dart';
import '../../../../../core/components/custom_button.dart';
import '../../../../../core/components/bottom_action_sheet_container.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../address/data/models/address_model.dart';
import '../../../../address/presentation/controllers/addresses_controller/addresses_cubit.dart';
import '../../../../address/presentation/controllers/maps_controller/maps_cubit.dart';
import '../../controllers/booking_cubit.dart';

class BookingLocationBottomActionSheet extends StatelessWidget {
  final int selectedLocationIndex;
  final AddressModel? selectedMapAddress;

  const BookingLocationBottomActionSheet({
    super.key,
    required this.selectedLocationIndex,
    required this.selectedMapAddress,
  });

  bool _isLocationValid(MapsState mapsState, AddressesState addressesState) {
    if (selectedLocationIndex == 0) {
      return mapsState.selectedAddressName.isNotEmpty;
    } else if (selectedLocationIndex == -1) {
      return selectedMapAddress != null;
    } else {
      if (addressesState is AddressesLoaded) {
        return selectedLocationIndex <= addressesState.addresses.length;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapsCubit, MapsState>(
      builder: (context, mapsState) {
        return BlocBuilder<AddressesCubit, AddressesState>(
          builder: (context, addressesState) {
            final isValid = _isLocationValid(mapsState, addressesState);
            return BottomActionSheetContainer(
              child: CustomButton(
                enabled: isValid,
                text: LocaleKeys.bookings_save_car_location.tr(
                  context: context,
                ),
                onPressed: () async {
                  AddressModel? address;
                  if (selectedLocationIndex == 0) {
                    address = AddressModel(
                      id: 'current_gps',
                      label: LocaleKeys.address_current_location.tr(
                        context: context,
                      ),
                      details: mapsState.selectedAddressName,
                      lat: mapsState.currentPosition?.latitude ?? 0.0,
                      lng: mapsState.currentPosition?.longitude ?? 0.0,
                    );
                  } else if (selectedLocationIndex == -1) {
                    address = selectedMapAddress;
                  } else if (addressesState is AddressesLoaded) {
                    address =
                        addressesState.addresses[selectedLocationIndex - 1];
                  }

                  if (address != null) {
                    final cubit = context.read<BookingCubit>();
                    context.showLoadingOverlay();
                    final isAvailable = await cubit.checkZone(
                      address.lat,
                      address.lng,
                    );
                    if (!context.mounted) return;
                    context.hideLoadingOverlay();

                    if (!isAvailable) {
                      // checkZone stores failure.message in state.errorMessage on
                      // failure; surface the backend reason and fall back to the
                      // generic localized zone-not-available message.
                      final reason = cubit.state.errorMessage;
                      context.showErrorSnackBar(
                        (reason != null && reason.isNotEmpty)
                            ? reason
                            : LocaleKeys.address_zone_not_available.tr(
                                context: context,
                              ),
                      );
                      return;
                    }

                    context.read<BookingCubit>().selectAddress(address);
                  }

                  if (!context.mounted) return;
                  context.pushNamed(
                    Routes.bookingDetails,
                    arguments: BookingFlowArgs(
                      bookingCubit: context.read<BookingCubit>(),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
