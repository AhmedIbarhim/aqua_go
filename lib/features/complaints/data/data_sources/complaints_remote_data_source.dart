import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class ComplaintsRemoteDataSource {
  final APIClient _apiClient;

  ComplaintsRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> getComplaints() {
    return _apiClient.get(Endpoints.complaints);
  }

  Future<Either<Failure, dynamic>> getComplaintDetail(String id) {
    return _apiClient.get(Endpoints.complaintDetail(id));
  }

  Future<Either<Failure, dynamic>> createComplaint({
    required Map<String, dynamic> complaintData,
    required String idempotencyKey,
  }) {
    return _apiClient.post(
      Endpoints.complaints,
      data: complaintData,
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
  }

  Future<Either<Failure, dynamic>> presignComplaintPhoto({
    required String complaintId,
    required Map<String, dynamic> data,
    required String idempotencyKey,
  }) {
    return _apiClient.post(
      Endpoints.complaintPhotoPresign(complaintId),
      data: data,
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
  }
}
