part of 'maps_cubit.dart';

class MapsState extends Equatable {
  final Position? currentPosition;
  final bool isLoading;
  final Set<Marker> markers;
  final bool showSearchResults;
  final String selectedAddressName;
  final List<PlacePredictionModel> placePredictions;
  final String? errorMessage;
  final bool isLocationServiceEnabled;

  const MapsState({
    this.currentPosition,
    this.isLoading = false,
    this.markers = const {},
    this.showSearchResults = false,
    this.selectedAddressName = '',
    this.placePredictions = const [],
    this.errorMessage,
    this.isLocationServiceEnabled = true,
  });

  MapsState copyWith({
    Position? currentPosition,
    bool? isLoading,
    Set<Marker>? markers,
    bool? showSearchResults,
    String? selectedAddressName,
    List<PlacePredictionModel>? placePredictions,
    String? errorMessage,
    bool? isLocationServiceEnabled,
  }) {
    return MapsState(
      currentPosition: currentPosition ?? this.currentPosition,
      isLoading: isLoading ?? this.isLoading,
      markers: markers ?? this.markers,
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
    markers,
    showSearchResults,
    selectedAddressName,
    placePredictions,
    errorMessage,
    isLocationServiceEnabled,
  ];
}
