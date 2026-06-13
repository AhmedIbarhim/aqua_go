import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/features/address/data/models/address_model.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'my_address_card.dart';
import 'add_address_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/addresses_controller/addresses_cubit.dart';

class MyAddressesList extends StatelessWidget {
  const MyAddressesList({super.key, required this.myAddresses});

  final List<AddressModel> myAddresses;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: myAddresses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final address = myAddresses[index];
        return MyAddressCard(
          address: address,
          onEdit: () {
            AddAddressBottomSheet.show(
              context: context,
              address: address.details,
              lat: address.lat,
              lng: address.lng,
              addressesCubit: context.read<AddressesCubit>(),
              existingAddress: address,
            );
          },
          onDelete: () {
            context.showWarningAlert(
              message: LocaleKeys.address_confirm_delete.tr(),
              onPrimaryPressed: () {
                context.read<AddressesCubit>().deleteAddress(address.id!);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
