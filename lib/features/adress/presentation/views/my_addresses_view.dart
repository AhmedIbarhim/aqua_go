import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/features/adress/data/models/address_model.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../widgets/empty_addresses_widget.dart';
import '../widgets/my_addresses_list.dart';
import 'new_address_map_view.dart';

class MyAddressesView extends StatelessWidget {
  const MyAddressesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data based on design
    final List<AddressModel> myAddresses = [
      AddressModel(
        name: 'المكتب',
        formattedAddress: '12شارع الماسة, الرياض السعودية',
        lat: 24.7136,
        lng: 46.6753,
      ),
      AddressModel(
        name: 'المنزل',
        formattedAddress: '12شارع الماسة, الرياض السعودية',
        lat: 24.7136,
        lng: 46.6753,
      ),
    ];

    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.address_my_addresses.tr(),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: myAddresses.isEmpty
                ? const EmptyAddressesWidget()
                : MyAddressesList(myAddresses: myAddresses),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              decoration: BoxDecoration(color: context.colors.screenBG),
              child: CustomButton(
                text: LocaleKeys.address_add_new_location.tr(),
                preWidget: Icon(
                  Icons.add,
                  // color: context.colors.textTheme,
                  size: 24,
                ),
                onPressed: () {
                  context.pushNamed(
                    Routes.newAddressMap,
                    arguments: NewAddressMapArgs(forAddingAddress: true),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
