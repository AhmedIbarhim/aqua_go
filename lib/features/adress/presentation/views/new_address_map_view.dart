import 'dart:async';
import 'dart:ui';
import 'package:aqua_go/core/components/custom_loading_indicator.dart';
import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aqua_go/core/components/custom_button.dart';
import 'package:dio/dio.dart';
import '../widgets/location_search_field.dart';
import '../widgets/add_address_bottom_sheet.dart';

class NewAddressMapView extends StatefulWidget {
  const NewAddressMapView({super.key, this.forAddingAddess = false});

  final bool forAddingAddess;

  @override
  State<NewAddressMapView> createState() => _NewAddressMapViewState();
}

class _NewAddressMapViewState extends State<NewAddressMapView> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();

  Position? _currentPosition;
  bool _isLoading = true;
  Set<Marker> _markers = {};
  bool _showSearchResults = false;
  String _selectedAddressName = '';
  List<dynamic> _placePredictions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.screenBG,
      body: _isLoading
          ? const Center(child: CustomLoadingIndicator(size: 100))
          : Stack(
              children: [
                // Map Background
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition?.latitude ?? 21.5433,
                      _currentPosition?.longitude ?? 39.1728,
                    ),
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: _markers,
                  onTap: (latLng) {
                    setState(() {
                      _markers = {
                        Marker(
                          markerId: const MarkerId('selected_location'),
                          position: latLng,
                        ),
                      };
                    });
                    _getAddressFromLatLng(latLng);
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
                    predictions: _placePredictions,
                    showResults: _showSearchResults,
                    onSearchChanged: _onSearchChanged,
                    onClear: () {
                      _searchController.clear();
                      setState(() {
                        _placePredictions = [];
                        _showSearchResults = false;
                      });
                    },
                    onPredictionTap: _getPlaceDetails,
                  ),
                ),

                // Return to current location button
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.2,
                  right: MediaQuery.of(context).size.width * 0.05,
                  child: InkWell(
                    onTap: _goToCurrentLocation,
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
                      text: LocaleKeys.address_continue.tr(),
                      onPressed: () {
                        if (widget.forAddingAddess) {
                          AddAddressBottomSheet.show(
                            context,
                            _selectedAddressName,
                          );
                        } else {}
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // screen functions

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    const String apiKey = 'AIzaSyCBWbLd9irc4PCEchf4WEMdIY8Io-PnScc';
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$apiKey&language=ar';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200 && response.data['results'].isNotEmpty) {
        setState(() {
          _selectedAddressName =
              response.data['results'][0]['formatted_address'];
          _searchController.text = _selectedAddressName;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _getAutocomplete(query);
      } else {
        setState(() {
          _placePredictions = [];
          _showSearchResults = false;
        });
      }
    });
  }

  Future<void> _getAutocomplete(String query) async {
    const String apiKey = 'AIzaSyCBWbLd9irc4PCEchf4WEMdIY8Io-PnScc';
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey&language=ar&components=country:sa';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        setState(() {
          _placePredictions = response.data['predictions'];
          _showSearchResults = _placePredictions.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    const String apiKey = 'AIzaSyCBWbLd9irc4PCEchf4WEMdIY8Io-PnScc';
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final location = response.data['result']['geometry']['location'];
        final latLng = LatLng(location['lat'], location['lng']);

        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));

        setState(() {
          _markers = {
            Marker(
              markerId: const MarkerId('selected_location'),
              position: latLng,
            ),
          };
          _showSearchResults = false;
          _selectedAddressName =
              response.data['result']['formatted_address'] ??
              response.data['result']['name'] ??
              '';
          _searchController.text = _selectedAddressName;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentPosition != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 15,
          ),
        ),
      );
    } else {
      _determinePosition();
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _isLoading = false;
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(position.latitude, position.longitude),
        ),
      );
    });
    _getAddressFromLatLng(LatLng(position.latitude, position.longitude));
  }
}
