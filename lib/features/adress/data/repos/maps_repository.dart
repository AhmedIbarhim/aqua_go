import 'package:aqua_go/core/errors/failure.dart';
import 'package:aqua_go/features/adress/data/models/location_model.dart';
import 'package:aqua_go/features/adress/data/models/place_prediction_model.dart';
import 'package:dartz/dartz.dart';
import '../services/location_service.dart';

class MapsRepository {
  final LocationService locationService;

  const MapsRepository({required this.locationService});

  Future<Either<Failure, List<PlacePredictionModel>>> getAutocomplete(
    String query,
  ) async {
    final result = await locationService.getAutocomplete(query);
    return result.fold(
      (failure) => Left(failure),
      (response) {
        if (response.statusCode == 200 && response.data['status'] == 'OK') {
          final predictions = (response.data['predictions'] as List)
              .map((e) => PlacePredictionModel.fromJson(e))
              .toList();
          return Right(predictions);
        } else {
          return Left(
            ServerFailure(
              response.data['error_message'] ?? 'Failed to get predictions',
            ),
          );
        }
      },
    );
  }

  Future<Either<Failure, LocationModel>> getPlaceDetails(String placeId) async {
    final result = await locationService.getPlaceDetails(placeId);
    return result.fold(
      (failure) => Left(failure),
      (response) {
        if (response.statusCode == 200 && response.data['status'] == 'OK') {
          return Right(LocationModel.fromPlaceDetailsJson(response.data));
        } else {
          return Left(
            ServerFailure(
              response.data['error_message'] ?? 'Failed to get place details',
            ),
          );
        }
      },
    );
  }

  Future<Either<Failure, LocationModel>> getAddressFromLatLng(
    double lat,
    double lng,
  ) async {
    final result = await locationService.getAddressFromLatLng(lat, lng);
    return result.fold(
      (failure) => Left(failure),
      (response) {
        if (response.statusCode == 200 &&
            response.data['status'] == 'OK' &&
            response.data['results'].isNotEmpty) {
          return Right(
            LocationModel.fromGeocodeJson(response.data['results'][0]),
          );
        } else {
          return Left(
            ServerFailure(
              response.data['error_message'] ?? 'Failed to get address',
            ),
          );
        }
      },
    );
  }
}
