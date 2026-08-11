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

  static const _uuid = Uuid();
  String? _sessionToken;

  String _currentSessionToken() => _sessionToken ??= _uuid.v4();

  bool _editSeeded = false;

  static const Duration _positionTimeLimit = Duration(seconds: 15);

  void _monitorLocationService() {
    _serviceStatusSubscription = Geolocator.getServiceStatusStream().listen((
      status,
    ) {
      if (status == ServiceStatus.enabled) {
        emit(state.copyWith(isLocationServiceEnabled: true));
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

  void onCameraMove(LatLng target) {
    emit(state.copyWith(selectedLatLng: target));
  }

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
