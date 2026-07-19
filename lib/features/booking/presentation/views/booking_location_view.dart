import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../generated/locale_keys.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../../address/presentation/controllers/addresses_controller/addresses_cubit.dart';
import '../../../address/presentation/controllers/maps_controller/maps_cubit.dart';
import '../../../address/presentation/views/new_address_map_view.dart';
import '../widgets/booking_location_widgets/address_select_on_map_card.dart';
import '../widgets/booking_location_widgets/gps_location_card.dart';
import '../widgets/booking_location_widgets/saved_locations_list.dart';
import '../../../address/data/models/address_model.dart';
import '../controllers/booking_cubit.dart';
import '../controllers/booking_state.dart';
import '../widgets/booking_location_widgets/booking_location_bottom_action_sheet.dart';

class BookingLocationView extends StatefulWidget {
  const BookingLocationView({super.key});

  @override
  State<BookingLocationView> createState() => _BookingLocationViewState();
}

class _BookingLocationViewState extends State<BookingLocationView> {
  late final AddressesCubit _addressCubit;
  late final MapsCubit _mapsCubit;
  int selectedLocationIndex = 0;
  AddressModel? selectedMapAddress;
  bool _addressJustAdded = false;
  List<AddressModel> _previousAddresses = [];

  @override
  void initState() {
    _addressCubit = locator<AddressesCubit>()..getAddresses();
    _mapsCubit = locator<MapsCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapsCubit.determinePosition();

      // Initialize selected location from booking cubit state if present
      final bookingCubit = context.read<BookingCubit>();
      final selectedAddr = bookingCubit.state.selectedAddress;
      if (selectedAddr != null) {
        if (selectedAddr.id == 'current_gps') {
          setState(() {
            selectedLocationIndex = 0;
          });
        } else if (selectedAddr.id == 'custom_map') {
          setState(() {
            selectedLocationIndex = -1;
            selectedMapAddress = selectedAddr;
          });
        } else {
          setState(() {
            selectedLocationIndex = -1;
            selectedMapAddress = selectedAddr;
          });
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _addressCubit.close();
    _mapsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _mapsCubit),
        BlocProvider.value(value: _addressCubit),
      ],
      child: Scaffold(
        backgroundColor: context.colors.screenBG,
        appBar: GenericAppBar(
          title: LocaleKeys.bookings_choose_car_location.tr(context: context),
          titleColor: context.colors.textPrimary,
          hasBackground: true,
          backgroundImage: context.isDarkTheme
              ? AppAssets.bookingHeaderImageDark
              : AppAssets.bookingHeaderImageLight,
          centerTitle: true,
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<MapsCubit, MapsState>(
              listenWhen: (prev, curr) =>
                  prev.isLocationServiceEnabled !=
                      curr.isLocationServiceEnabled ||
                  prev.errorMessage != curr.errorMessage ||
                  prev.isLoading != curr.isLoading,
              listener: (context, state) {
                if (state.isLoading) {
                  context.showLoadingOverlay();
                } else {
                  context.hideLoadingOverlay();
                }

                if (!state.isLocationServiceEnabled) {
                  context.showDialogBox(
                    message: LocaleKeys.address_location_disabled_message.tr(
                      context: context,
                    ),
                    mainButtonText: LocaleKeys.address_go_to_settings.tr(
                      context: context,
                    ),
                    onMainButtonPressed: () {
                      Navigator.pop(context);
                      _mapsCubit.openLocationSettings();
                    },
                  );
                } else if (state.errorMessage != null) {
                  context.showErrorSnackBar(state.errorMessage!);
                }
              },
            ),
            BlocListener<AddressesCubit, AddressesState>(
              listener: (context, state) {
                if (state is AddressesLoaded) {
                  if (_addressJustAdded) {
                    _addressJustAdded = false;
                    AddressModel? newAddress;
                    for (final addr in state.addresses) {
                      final exists = _previousAddresses.any(
                        (oldAddr) => oldAddr.id == addr.id,
                      );
                      if (!exists) {
                        newAddress = addr;
                        break;
                      }
                    }
                    if (newAddress != null) {
                      final idx = state.addresses.indexOf(newAddress);
                      setState(() {
                        selectedLocationIndex = idx + 1;
                      });
                    } else if (state.addresses.isNotEmpty) {
                      setState(() {
                        selectedLocationIndex = state.addresses.length;
                      });
                    }
                  } else {
                    final selectedAddr = context
                        .read<BookingCubit>()
                        .state
                        .selectedAddress;
                    if (selectedAddr != null &&
                        selectedAddr.id != 'current_gps' &&
                        selectedAddr.id != 'custom_map') {
                      final idx = state.addresses.indexWhere(
                        (addr) =>
                            addr.id == selectedAddr.id ||
                            (addr.lat == selectedAddr.lat &&
                                addr.lng == selectedAddr.lng),
                      );
                      if (idx != -1) {
                        setState(() {
                          selectedLocationIndex = idx + 1;
                        });
                      } else {
                        setState(() {
                          selectedLocationIndex = -1;
                          selectedMapAddress = selectedAddr;
                        });
                      }
                    }
                  }
                  _previousAddresses = state.addresses;
                }
              },
            ),
            BlocListener<BookingCubit, BookingState>(
              listenWhen: (prev, curr) => prev.status != curr.status,
              listener: (context, state) {
                if (state.status == BookingStatus.loading) {
                  context.showLoadingOverlay();
                } else {
                  context.hideLoadingOverlay();
                }
                if (state.status == BookingStatus.failure &&
                    state.errorMessage != null) {
                  context.showErrorSnackBar(state.errorMessage!);
                }
              },
            ),
          ],
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(width * 0.06),
                          decoration: BoxDecoration(
                            color: context.colors.background,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocaleKeys.address_map.tr(context: context),
                                style: AppTextStyles.regular16.copyWith(
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              SizedBox(height: height * 0.01),
                              GpsLocationCard(
                                isSelected: selectedLocationIndex == 0,
                                onTap: () {
                                  setState(() {
                                    selectedLocationIndex = 0;
                                  });
                                },
                              ),
                              SizedBox(height: height * 0.02),
                              AddressSelectOnMapCard(
                                isSelected: selectedLocationIndex == -1,
                                selectedMapAddress: selectedMapAddress,
                                onTap: () async {
                                  final result = await context.pushNamed(
                                    Routes.newAddressMap,
                                    arguments: NewAddressMapArgs(
                                      forAddingAddress: false,
                                    ),
                                  );
                                  if (result != null &&
                                      result is Map<String, dynamic>) {
                                    setState(() {
                                      selectedLocationIndex = -1;
                                      selectedMapAddress = AddressModel(
                                        id: 'custom_map',
                                        label: LocaleKeys.address_select_on_map
                                            .tr(context: context),
                                        details: result['address'] ?? '',
                                        lat: result['lat'] ?? 0.0,
                                        lng: result['lng'] ?? 0.0,
                                      );
                                    });
                                  } else if (selectedMapAddress != null) {
                                    setState(() {
                                      selectedLocationIndex = -1;
                                    });
                                  }
                                },
                              ),
                              SizedBox(height: height * 0.03),
                              Text(
                                LocaleKeys.address_my_addresses.tr(
                                  context: context,
                                ),
                                style: AppTextStyles.regular16.copyWith(
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              SizedBox(height: height * 0.01),
                              SavedLocationsList(
                                selectedLocationIndex: selectedLocationIndex,
                                onAddressSelected: (index) {
                                  setState(() {
                                    selectedLocationIndex = index;
                                  });
                                },
                                addressesCubit: _addressCubit,
                              ),
                              SizedBox(height: height * 0.01),
                              CustomButton(
                                color: context.colors.background,
                                borderColor: context.colors.borderSecondary,
                                textColor: context.colors.primary,
                                preWidget: Icon(
                                  Icons.add,
                                  color: context.colors.primary,
                                  size: width * 0.06,
                                ),
                                text: LocaleKeys.address_add_new_location.tr(
                                  context: context,
                                ),
                                onPressed: () {
                                  context
                                      .pushNamed(
                                        Routes.newAddressMap,
                                        arguments: NewAddressMapArgs(
                                          forAddingAddress: true,
                                        ),
                                      )
                                      .then((val) {
                                        if (val == true && context.mounted) {
                                          setState(() {
                                            _addressJustAdded = true;
                                          });
                                          _addressCubit.getAddresses();
                                        }
                                      });
                                },
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              BookingLocationBottomActionSheet(
                selectedLocationIndex: selectedLocationIndex,
                selectedMapAddress: selectedMapAddress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
