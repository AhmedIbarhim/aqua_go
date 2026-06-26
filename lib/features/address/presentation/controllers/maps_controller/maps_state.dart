part of 'maps_cubit.dart';

class MapsState extends Equatable {
  final Position? currentPosition;
  final bool isLoading;

  /// The geographic point currently under the center pin (camera target).
  /// This is the selected-location source of truth — markers are no longer
  /// used to carry the chosen point (center-pinned picker).
  final LatLng? selectedLatLng;

  /// Camera target to move the map to (search result / my-location).
  /// Bumped via [cameraMoveToken] so identical successive targets still fire.
  final LatLng? cameraMoveTarget;
  final int cameraMoveToken;

  final bool showSearchResults;
  final String selectedAddressName;
  final List<PlacePredictionModel> placePredictions;
  final String? errorMessage;
  final bool isLocationServiceEnabled;

  const MapsState({
    this.currentPosition,
    this.isLoading = false,
    this.selectedLatLng,
    this.cameraMoveTarget,
    this.cameraMoveToken = 0,
    this.showSearchResults = false,
    this.selectedAddressName = '',
    this.placePredictions = const [],
    this.errorMessage,
    this.isLocationServiceEnabled = true,
  });

  MapsState copyWith({
    Position? currentPosition,
    bool? isLoading,
    LatLng? selectedLatLng,
    LatLng? cameraMoveTarget,
    int? cameraMoveToken,
    bool? showSearchResults,
    String? selectedAddressName,
    List<PlacePredictionModel>? placePredictions,
    String? errorMessage,
    bool? isLocationServiceEnabled,
  }) {
    return MapsState(
      currentPosition: currentPosition ?? this.currentPosition,
      isLoading: isLoading ?? this.isLoading,
      selectedLatLng: selectedLatLng ?? this.selectedLatLng,
      cameraMoveTarget: cameraMoveTarget ?? this.cameraMoveTarget,
      cameraMoveToken: cameraMoveToken ?? this.cameraMoveToken,
      showSearchResults: showSearchResults ?? this.showSearchResults,
      selectedAddressName: selectedAddressName ?? this.selectedAddressName,
      placePredictions: placePredictions ?? this.placePredictions,
      errorMessage: errorMessage,
      isLocationServiceEnabled:
          isLocationServiceEnabled ?? this.isLocationServiceEnabled,
    );
  }

  @override
  List<Object?> get props => [
    currentPosition,
    isLoading,
    selectedLatLng,
    cameraMoveTarget,
    cameraMoveToken,
    showSearchResults,
    selectedAddressName,
    placePredictions,
    errorMessage,
    isLocationServiceEnabled,
  ];
}
