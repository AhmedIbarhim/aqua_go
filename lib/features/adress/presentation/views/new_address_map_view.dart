import 'dart:async';
import 'dart:ui';
import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:aqua_go/features/adress/controllers/maps_controller/maps_cubit.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:aqua_go/core/components/custom_button.dart';
import '../widgets/location_search_field.dart';
import '../widgets/add_address_bottom_sheet.dart';

class NewAddressMapView extends StatefulWidget {
  const NewAddressMapView({super.key, this.forAddingAddess = false});

  final bool forAddingAddess;

  @override
  State<NewAddressMapView> createState() => _NewAddressMapViewState();
}

class _NewAddressMapViewState extends State<NewAddressMapView> {
  late MapsCubit _mapsCubit;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mapsCubit = locator<MapsCubit>();
    _mapsCubit.determinePosition();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _mapsCubit,
      child: BlocListener<MapsCubit, MapsState>(
        listenWhen: (previous, current) =>
            previous.selectedAddressName != current.selectedAddressName,
        listener: (context, state) {
          if (state.selectedAddressName.isNotEmpty) {
            _searchController.text = state.selectedAddressName;
          }
        },
        child: Scaffold(
          backgroundColor: context.colors.screenBG,
          body: BlocBuilder<MapsCubit, MapsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CustomLoadingIndicator(size: 100));
              }

              return Stack(
                children: [
                  // Map Background
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        state.currentPosition?.latitude ?? 21.5433,
                        state.currentPosition?.longitude ?? 39.1728,
                      ),
                      zoom: 15,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    markers: state.markers,
                    onTap: (latLng) {
                      context.read<MapsCubit>().onMapTap(latLng);
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    padding: const EdgeInsets.only(bottom: 150),
                  ),

                  // Search Bar Overlay
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 24,
                    right: 24,
                    child: LocationSearchField(
                      controller: _searchController,
                      predictions: state.placePredictions,
                      showResults: state.showSearchResults,
                      onSearchChanged: (query) {
                        context.read<MapsCubit>().onSearchChanged(query);
                      },
                      onClear: () {
                        _searchController.clear();
                        context.read<MapsCubit>().clearSearch();
                      },
                      onPredictionTap: (placeId) {
                        context.read<MapsCubit>().getPlaceDetails(
                          placeId,
                          onLocationFound: (latLng) async {
                            final controller = await _controller.future;
                            controller.animateCamera(
                              CameraUpdate.newLatLngZoom(latLng, 15),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Return to current location button
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.2,
                    right: MediaQuery.of(context).size.width * 0.05,
                    child: InkWell(
                      onTap: () => _goToCurrentLocation(context, state),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: darkAppColors.themeColor.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: darkAppColors.textSecondary,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.my_location,
                                color: lightAppColors.themeColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: 48,
                        top: 24,
                      ),
                      decoration: BoxDecoration(color: context.colors.screenBG),
                      child: CustomButton(
                        text: LocaleKeys.proceed.tr(),
                        onPressed: () {
                          if (widget.forAddingAddess) {
                            AddAddressBottomSheet.show(
                              context,
                              state.selectedAddressName,
                            );
                          } else {}
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _goToCurrentLocation(
    BuildContext context,
    MapsState state,
  ) async {
    if (state.currentPosition != null) {
      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              state.currentPosition!.latitude,
              state.currentPosition!.longitude,
            ),
            zoom: 15,
          ),
        ),
      );
    } else {
      context.read<MapsCubit>().determinePosition();
    }
  }
}
