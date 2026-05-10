import 'package:aqua_go/core/errors/failure.dart';
import 'package:aqua_go/features/adress/data/models/location_model.dart';
import 'package:aqua_go/features/adress/data/models/place_prediction_model.dart';
import 'package:dartz/dartz.dart';
import '../services/location_service.dart';

class MapsRepository {
  final LocationService locationService;

  MapsRepository({required this.locationService});

  Future<Either<Failure, List<PlacePredictionModel>>> getAutocomplete(
    String query,
  ) async {
    try {
      final response = await locationService.getAutocomplete(query);
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
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, LocationModel>> getPlaceDetails(String placeId) async {
    try {
      final response = await locationService.getPlaceDetails(placeId);
      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        return Right(LocationModel.fromPlaceDetailsJson(response.data));
      } else {
        return Left(
          ServerFailure(
            response.data['error_message'] ?? 'Failed to get place details',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, LocationModel>> getAddressFromLatLng(
    double lat,
    double lng,
  ) async {
    try {
      final response = await locationService.getAddressFromLatLng(lat, lng);
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
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
