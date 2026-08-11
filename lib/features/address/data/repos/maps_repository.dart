import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/address/data/models/location_model.dart';
import 'package:aqua_go/features/address/data/models/place_prediction_model.dart';
import 'package:dartz/dartz.dart';
import '../services/location_service.dart';

class MapsRepository {
  final LocationService locationService;

  const MapsRepository({required this.locationService});

  Future<Either<Failure, List<PlacePredictionModel>>> getAutocomplete(
    String query,
    String sessionToken,
  ) async {
    final result = await locationService.getAutocomplete(query, sessionToken);
    return result.fold((failure) => Left(failure), (data) {
      final suggestions = (data?['suggestions'] as List?) ?? const [];
      final predictions = suggestions
          .map((e) => PlacePredictionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(predictions);
    });
  }

  Future<Either<Failure, LocationModel>> getPlaceDetails(String placeId) async {
    final result = await locationService.getPlaceDetails(placeId);
    return result.fold((failure) => Left(failure), (data) {
      if (data == null) {
        return const Left(ServerFailure('Failed to get place details'));
      }
      return Right(LocationModel.fromJson(data as Map<String, dynamic>));
    });
  }

  Future<Either<Failure, LocationModel>> getAddressFromLatLng(
    double lat,
    double lng,
  ) async {
    final result = await locationService.getAddressFromLatLng(lat, lng);
    return result.fold((failure) => Left(failure), (data) {
      if (data == null) {
        return const Left(ServerFailure('Failed to get address'));
      }
      return Right(LocationModel.fromJson(data as Map<String, dynamic>));
    });
  }
}
