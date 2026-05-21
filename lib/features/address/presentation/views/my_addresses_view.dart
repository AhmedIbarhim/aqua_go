import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/components/generic_app_bar.dart';
import 'package:aqua_go/features/address/data/models/address_model.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../widgets/empty_addresses_widget.dart';
import '../widgets/my_addresses_list.dart';
import '../../../../core/components/bottom_action_sheet_container.dart';
import 'new_address_map_view.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../controllers/addresses_controller/addresses_cubit.dart';
import '../../../../core/helpers/shimmer_helper.dart';

class MyAddressesView extends StatefulWidget {
  const MyAddressesView({super.key});

  @override
  State<MyAddressesView> createState() => _MyAddressesViewState();
}

class _MyAddressesViewState extends State<MyAddressesView> {
  late final AddressesCubit _addressesCubit;

  @override
  void initState() {
    _addressesCubit = locator<AddressesCubit>()..getAddresses();
    super.initState();
  }

  @override
  void dispose() {
    _addressesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return BlocProvider.value(
      value: _addressesCubit,
      child: Scaffold(
        backgroundColor: context.colors.screenBG,
        appBar: GenericAppBar(
          title: LocaleKeys.address_my_addresses.tr(),
          centerTitle: true,
        ),
        body: BlocConsumer<AddressesCubit, AddressesState>(
          listener: (context, state) {
            if (state is AddressesActionLoading) {
              context.showLoadingOverlay();
            } else {
              context.hideLoadingOverlay();
            }

            if (state is AddressesActionError) {
              context.showWarningAlert(
                title: 'Error',
                message: state.message,
                primaryButtonText: 'OK',
              );
            }
          },
          buildWhen: (previous, current) =>
              current is AddressesLoading ||
              current is AddressesLoaded ||
              current is AddressesError ||
              current is AddressesInitial,
          builder: (context, state) {
            if (state is AddressesLoading || state is AddressesInitial) {
              return Padding(
                padding: EdgeInsets.all(width * 0.06),
                child: ShimmerHelper.addresses(),
              );
            }

            if (state is AddressesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: TextStyle(
                        color: context.colors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _addressesCubit.getAddresses(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final List<AddressModel> myAddresses = state is AddressesLoaded
                ? state.addresses
                : <AddressModel>[];

            return Column(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(width * 0.06),
                    decoration: BoxDecoration(
                      color: context.colors.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: myAddresses.isEmpty
                        ? const SingleChildScrollView(
                            child: EmptyAddressesWidget(),
                          )
                        : MyAddressesList(myAddresses: myAddresses),
                  ),
                ),
                _buildBottomActionSheet(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomActionSheet(BuildContext context) {
    return BottomActionSheetContainer(
      child: CustomButton(
        text: LocaleKeys.address_add_new_location.tr(),
        preWidget: const Icon(Icons.add, size: 24),
        onPressed: () {
          context.pushNamed(
            Routes.newAddressMap,
            arguments: NewAddressMapArgs(forAddingAddress: true),
          );
        },
      ),
    );
  }
}
