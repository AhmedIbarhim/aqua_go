import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../../../generated/locale_keys.g.dart';
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

  // PH1-005: one Google billing session groups the autocomplete calls of a
  // single search until the user picks a result (or clears). Minted lazily on
  // the first keystroke; reset once a place is selected or the search clears.
  static const _uuid = Uuid();
  String? _sessionToken;

  String _currentSessionToken() => _sessionToken ??= _uuid.v4();

  /// True once [seedLocation] has run (edit path). Prevents the location-service
  /// stream from recentering the camera onto current GPS and clobbering the
  /// seeded saved location (AQG-243).
  bool _editSeeded = false;

  /// Bounds the platform location fix in [determinePosition]. Without this,
  /// a device that never gets a fix (indoors, GPS off, airplane mode, or the
  /// iOS Simulator's "Location > None") leaves `getCurrentPosition` awaiting
  /// forever, so `isLoading` never clears and the screen is stuck on a
  /// spinner with no escape.
  static const Duration _positionTimeLimit = Duration(seconds: 15);

  void _monitorLocationService() {
    _serviceStatusSubscription = Geolocator.getServiceStatusStream().listen((
      status,
    ) {
      if (status == ServiceStatus.enabled) {
        emit(state.copyWith(isLocationServiceEnabled: true));
        // In edit mode the camera is already seeded to the saved location —
        // don't recenter to current GPS.
        if (!_editSeeded) {
          determinePosition();
        }
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
            errorMessage: LocaleKeys.address_location_permission_denied.tr(),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: LocaleKeys.address_location_permission_denied_forever
              .tr(),
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: _positionTimeLimit),
      );
      final latLng = LatLng(position.latitude, position.longitude);

      emit(
        state.copyWith(
          currentPosition: position,
          isLoading: false,
          selectedLatLng: latLng,
          cameraMoveTarget: latLng,
          cameraMoveToken: state.cameraMoveToken + 1,
        ),
      );

      getAddressFromLatLng(latLng);
    } on TimeoutException {
      // A cold GPS fix routinely takes longer than _positionTimeLimit, so a
      // timeout is NOT the same as "we have no idea where you are" — the OS
      // usually still holds a recent fix from another app. Fall back to it and
      // carry on silently; only tell the customer we failed when there is
      // genuinely nothing to show. Reporting an error while the map then
      // centres on their actual location reads as a bug, because it is one.
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        final latLng = LatLng(lastKnown.latitude, lastKnown.longitude);
        emit(
          state.copyWith(
            currentPosition: lastKnown,
            isLoading: false,
            selectedLatLng: latLng,
            cameraMoveTarget: latLng,
            cameraMoveToken: state.cameraMoveToken + 1,
          ),
        );
        getAddressFromLatLng(latLng);
        return;
      }
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: LocaleKeys.address_location_unavailable.tr(),
        ),
      );
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
        _sessionToken = null;
        emit(state.copyWith(placePredictions: [], showSearchResults: false));
      }
    });
  }

  Future<void> _getAutocomplete(String query) async {
    final result = await mapsRepository.getAutocomplete(
      query,
      _currentSessionToken(),
    );

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

  Future<void> getPlaceDetails(String placeId) async {
    final result = await mapsRepository.getPlaceDetails(placeId);

    // The billing session ends once a suggestion is resolved to a place.
    _sessionToken = null;

    result.fold((failure) => debugPrint(failure.message), (address) {
      final latLng = LatLng(address.lat, address.lng);
      emit(
        state.copyWith(
          selectedLatLng: latLng,
          cameraMoveTarget: latLng,
          cameraMoveToken: state.cameraMoveToken + 1,
          showSearchResults: false,
          selectedAddressName: address.formattedAddress,
        ),
      );
    });
  }

  /// Seeds the initial selected point (edit path) and recenters the camera.
  /// Reverse-geocodes once so Confirm is valid before any pan.
  void seedLocation(LatLng latLng) {
    _editSeeded = true;
    emit(
      state.copyWith(
        selectedLatLng: latLng,
        cameraMoveTarget: latLng,
        cameraMoveToken: state.cameraMoveToken + 1,
      ),
    );
    getAddressFromLatLng(latLng);
  }

  /// Called continuously while the map pans — cheap, no geocode.
  /// The camera target IS the geographic point under the screen-center pin.
  void onCameraMove(LatLng target) {
    emit(state.copyWith(selectedLatLng: target));
  }

  /// Called once when the map stops moving — reverse-geocode the final point.
  void onCameraIdle() {
    final latLng = state.selectedLatLng;
    if (latLng != null) {
      getAddressFromLatLng(latLng);
    }
  }

  void clearSearch() {
    _sessionToken = null;
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
