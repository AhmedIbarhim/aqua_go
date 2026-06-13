import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../../../data/repos/maps_repository.dart';
import '../../../data/models/place_prediction_model.dart';

part 'maps_state.dart';

class MapsCubit extends Cubit<MapsState> {
  final MapsRepository mapsRepository;

  MapsCubit({required this.mapsRepository}) : super(const MapsState()) {
    _monitorLocationService();
  }

  Timer? _debounce;
  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;

  void _monitorLocationService() {
    _serviceStatusSubscription = Geolocator.getServiceStatusStream().listen((
      status,
    ) {
      if (status == ServiceStatus.enabled) {
        emit(state.copyWith(isLocationServiceEnabled: true));
        determinePosition();
      } else {
        emit(state.copyWith(isLocationServiceEnabled: false));
      }
    });
  }

  Future<void> determinePosition() async {
    emit(state.copyWith(isLoading: true));

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(state.copyWith(isLoading: false, isLocationServiceEnabled: false));
      return;
    }
    emit(state.copyWith(isLocationServiceEnabled: true));

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Location permissions are denied.',
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Location permissions are permanently denied.',
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);

      final markers = {
        Marker(markerId: const MarkerId('current_location'), position: latLng),
      };

      emit(
        state.copyWith(
          currentPosition: position,
          isLoading: false,
          markers: markers,
        ),
      );

      getAddressFromLatLng(latLng);
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> getAddressFromLatLng(LatLng latLng) async {
    final result = await mapsRepository.getAddressFromLatLng(
      latLng.latitude,
      latLng.longitude,
    );

    result.fold(
      (failure) => debugPrint(failure.message),
      (address) =>
          emit(state.copyWith(selectedAddressName: address.formattedAddress)),
    );
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _getAutocomplete(query);
      } else {
        emit(state.copyWith(placePredictions: [], showSearchResults: false));
      }
    });
  }

  Future<void> _getAutocomplete(String query) async {
    final result = await mapsRepository.getAutocomplete(query);

    result.fold(
      (failure) => debugPrint(failure.message),
      (predictions) => emit(
        state.copyWith(
          placePredictions: predictions,
          showSearchResults: predictions.isNotEmpty,
        ),
      ),
    );
  }

  Future<void> getPlaceDetails(
    String placeId, {
    required Function(LatLng) onLocationFound,
  }) async {
    final result = await mapsRepository.getPlaceDetails(placeId);

    result.fold((failure) => debugPrint(failure.message), (address) {
      final latLng = LatLng(address.lat, address.lng);
      emit(
        state.copyWith(
          markers: {
            Marker(
              markerId: const MarkerId('selected_location'),
              position: latLng,
            ),
          },
          showSearchResults: false,
          selectedAddressName: address.formattedAddress,
        ),
      );
      onLocationFound(latLng);
    });
  }

  void onMapTap(LatLng latLng) {
    emit(
      state.copyWith(
        markers: {
          Marker(
            markerId: const MarkerId('selected_location'),
            position: latLng,
          ),
        },
      ),
    );
    getAddressFromLatLng(latLng);
  }

  void clearSearch() {
    emit(state.copyWith(placePredictions: [], showSearchResults: false));
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _serviceStatusSubscription?.cancel();
    return super.close();
  }
}
