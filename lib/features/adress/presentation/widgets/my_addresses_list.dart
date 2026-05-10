import 'package:aqua_go/core/components/custom_alert_box.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/features/adress/data/models/address_model.dart';
import 'package:aqua_go/features/adress/presentation/views/new_address_map_view.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'my_address_card.dart';

class MyAddressesList extends StatelessWidget {
  const MyAddressesList({
    super.key,
    required this.myAddresses,
  });

  final List<AddressModel> myAddresses;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: myAddresses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return MyAddressCard(
          address: myAddresses[index],
          onEdit: () {
            context.pushNamed(
              Routes.newAddressMap,
              arguments: NewAddressMapArgs(
                forAddingAddress: true,
              ),
            );
          },
          onDelete: () {
            WarningBox.show(
              context: context,
              message: LocaleKeys.address_confirm_delete.tr(),
              onPrimaryPressed: () {
                // TODO: Implement delete logic
              },
            );
          },
        );
      },
    );
  }
}
