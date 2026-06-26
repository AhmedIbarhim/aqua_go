import 'dart:async';
import 'dart:ui';
import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:aqua_go/features/address/presentation/controllers/maps_controller/maps_cubit.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:aqua_go/core/components/custom_button.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../data/models/address_model.dart';
import '../widgets/location_search_field.dart';
import '../widgets/add_address_bottom_sheet.dart';

/// Size of the center-pin marker. We use [Icons.location_on] — a filled
/// Material teardrop whose POINT sits exactly at the bottom-center of its
/// bounding box — so translating it up by half its size lands the tip on the
/// geometric-center pixel (== camera target). We deliberately do NOT use the
/// generic location.svg glyph: its visual point is not at the asset's bottom
/// edge, which made the prior -_kPinSize/2 offset land ~10-15m off-target.
const double _kPinSize = 48;

/// Diameter of the tiny precise dot drawn at the exact geometric center so the
/// chosen point is visible regardless of the pin artwork.
const double _kCenterDot = 6;

class NewAddressMapArgs {
  final bool forAddingAddress;
  final AddressModel? address;
  NewAddressMapArgs({required this.forAddingAddress, this.address});
}

class NewAddressMapView extends StatefulWidget {
  const NewAddressMapView({
    super.key,
    this.forAddingAddess = false,
    this.address,
  });

  final bool forAddingAddess;
  final AddressModel? address;

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
    if (widget.address != null) {
      _mapsCubit.seedLocation(LatLng(widget.address!.lat, widget.address!.lng));
      _searchController.text = widget.address!.details;
    } else {
      _mapsCubit.determinePosition();
    }
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
      child: MultiBlocListener(
        listeners: [
          BlocListener<MapsCubit, MapsState>(
            listenWhen: (previous, current) =>
                previous.selectedAddressName != current.selectedAddressName,
            listener: (context, state) {
              if (state.selectedAddressName.isNotEmpty) {
                _searchController.text = state.selectedAddressName;
              }
            },
          ),
          // Recenter the camera when the cubit requests it (initial position,
          // edit-seed, search result, my-location). onCameraIdle then re-reads
          // the settled target and reverse-geocodes — no marker is pushed.
          BlocListener<MapsCubit, MapsState>(
            listenWhen: (previous, current) =>
                previous.cameraMoveToken != current.cameraMoveToken,
            listener: (context, state) async {
              final target = state.cameraMoveTarget;
              if (target == null) return;
              final controller = await _controller.future;
              controller.animateCamera(
                CameraUpdate.newLatLngZoom(target, 15),
              );
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: context.colors.screenBG,
          body: BlocBuilder<MapsCubit, MapsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CustomLoadingIndicator(size: 100));
              }

              return Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        state.selectedLatLng?.latitude ??
                            state.currentPosition?.latitude ??
                            21.5433,
                        state.selectedLatLng?.longitude ??
                            state.currentPosition?.longitude ??
                            39.1728,
                      ),
                      zoom: 15,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      if (!_controller.isCompleted) {
                        _controller.complete(controller);
                      }
                    },
                    onCameraMove: (position) {
                      context.read<MapsCubit>().onCameraMove(position.target);
                    },
                    onCameraIdle: () {
                      context.read<MapsCubit>().onCameraIdle();
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),

                  // Center-pinned marker overlay. INVARIANT: pin bottom-point
                  // pixel == map geometric center == camera target. The
                  // GoogleMap carries NO camera padding, so the widget's
                  // geometric center equals the camera target; the teardrop's
                  // tip is moved onto that center pixel by translating it up
                  // half its size. A tiny dot marks the exact center so the
                  // chosen point is visible regardless of pin art.
                  // IgnorePointer so it never eats map pan/zoom gestures.
                  IgnorePointer(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // The teardrop pin, tip lifted onto the center pixel.
                          // Fill = app primary (cyan/teal CTA color).
                          Transform.translate(
                            offset: const Offset(0, -_kPinSize / 2),
                            child: Icon(
                              Icons.location_on,
                              size: _kPinSize,
                              color: lightAppColors.primary,
                            ),
                          ),
                          // Exact geometric-center dot == camera target.
                          // White fill contrasts against the primary pin so the
                          // precise target point stays visible.
                          Container(
                            width: _kCenterDot,
                            height: _kCenterDot,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: lightAppColors.primary,
                                width: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          margin: const EdgeInsetsDirectional.only(end: 8),
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: BackButton(
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
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
                              // The cubit emits the new cameraMoveTarget; the
                              // recenter BlocListener animates the map. The
                              // settled camera then drives onCameraIdle.
                              context.read<MapsCubit>().getPlaceDetails(placeId);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: MediaQuery.sizeOf(context).height * 0.2,
                    right: MediaQuery.sizeOf(context).width * 0.05,
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
                        text: LocaleKeys.proceed.tr(context: context),
                        onPressed: () {
                          _addAddress(context, state);
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

  void _addAddress(BuildContext context, MapsState state) {
    // Selected point is the camera-center pin (set on camera move/idle, seed,
    // search result, or my-location), no longer a tapped marker.
    final selected = state.selectedLatLng;
    if (selected == null) return;

    if (widget.forAddingAddess) {
      AddAddressBottomSheet.show(
        context: context,
        address: state.selectedAddressName,
        lat: selected.latitude,
        lng: selected.longitude,
        existingAddress: widget.address,
      );
    } else {
      Navigator.pop(context, {
        'address': state.selectedAddressName,
        'lat': selected.latitude,
        'lng': selected.longitude,
      });
    }
  }
}
