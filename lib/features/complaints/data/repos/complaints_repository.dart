import 'dart:io';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/core/helpers/fetch_user_data_helper.dart';
import 'package:aqua_go/features/complaints/data/data_sources/complaints_remote_data_source.dart';
import 'package:aqua_go/features/complaints/data/models/complaint_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class ComplaintsRepository {
  final ComplaintsRemoteDataSource _remoteDataSource;

  ComplaintsRepository(this._remoteDataSource);

  Future<Either<Failure, List<ComplaintModel>>> getComplaints() async {
    final result = await _remoteDataSource.getComplaints();
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final List<dynamic> list = data as List<dynamic>;
            final complaints = list
                .map((json) => ComplaintModel.fromJson(json as Map<String, dynamic>))
                .toList();
            return Right(complaints);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to load complaints'));
      },
    );
  }

  Future<Either<Failure, ComplaintModel>> getComplaintDetail(String id) async {
    final result = await _remoteDataSource.getComplaintDetail(id);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final complaint = ComplaintModel.fromJson(data as Map<String, dynamic>);
            return Right(complaint);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to load complaint details'));
      },
    );
  }

  Future<Either<Failure, ComplaintModel>> raiseComplaint({
    required String bookingId,
    required String category,
    required String description,
    String? desiredOutcome,
    String? preferredContactChannel,
    List<File> photos = const [],
  }) async {
    try {
      final userId = FetchUserData.getUserId();
      final nowToMinutes = DateTime.now().toIso8601String().substring(0, 16);
      final idempotencyKey = 'customer-complaint-raise:${userId}_${bookingId}_$nowToMinutes';

      final Map<String, dynamic> complaintData = {
        'bookingId': bookingId,
        'category': category,
        'description': description,
        if (desiredOutcome != null && desiredOutcome.isNotEmpty) 'desiredOutcome': desiredOutcome,
        if (preferredContactChannel != null && preferredContactChannel.isNotEmpty)
          'preferredContactChannel': preferredContactChannel,
      };

      final createResult = await _remoteDataSource.createComplaint(
        complaintData: complaintData,
        idempotencyKey: idempotencyKey,
      );

      return createResult.fold(
        (failure) => Left(failure),
        (data) async {
          if (data == null) {
            return const Left(ServerFailure('Failed to create complaint'));
          }
          try {
            final complaint = ComplaintModel.fromJson(data as Map<String, dynamic>);

            if (photos.isNotEmpty) {
              final uploadResult = await uploadPhotos(
                complaintId: complaint.id,
                photos: photos,
              );

              return uploadResult.fold(
                (f) => Right(complaint), // Return created complaint even if photo upload fails
                (_) async {
                  final detailResult = await getComplaintDetail(complaint.id);
                  return detailResult.fold(
                    (f) => Right(complaint),
                    (updatedComplaint) => Right(updatedComplaint),
                  );
                },
              );
            }

            return Right(complaint);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> uploadPhotos({
    required String complaintId,
    required List<File> photos,
  }) async {
    final dio = Dio();
    for (int i = 0; i < photos.length; i++) {
      final file = photos[i];
      if (!await file.exists()) continue;

      final sizeBytes = await file.length();
      final extension = file.path.split('.').last.toLowerCase();
      final contentType = (extension == 'jpg' || extension == 'jpeg')
          ? 'image/jpeg'
          : (extension == 'png' ? 'image/png' : 'application/octet-stream');

      final idempotencyKey = 'complaint-photo-presign:$complaintId:$i:${DateTime.now().millisecondsSinceEpoch}';

      final presignResult = await _remoteDataSource.presignComplaintPhoto(
        complaintId: complaintId,
        data: {
          'photoIndex': i,
          'contentType': contentType,
        },
        idempotencyKey: idempotencyKey,
      );

      bool uploadSuccess = false;
      if (presignResult.isRight()) {
        final data = presignResult.getOrElse(() => null);
        if (data != null) {
          final String? uploadUrl = data['url'];
          if (uploadUrl != null && uploadUrl.isNotEmpty) {
            try {
              final bytes = await file.readAsBytes();
              final uploadResponse = await dio.put(
                uploadUrl,
                data: Stream.fromIterable([bytes]),
                options: Options(
                  headers: {
                    Headers.contentTypeHeader: contentType,
                    Headers.contentLengthHeader: sizeBytes,
                  },
                ),
              );
              uploadSuccess = uploadResponse.statusCode == 200 ||
                  uploadResponse.statusCode == 201 ||
                  uploadResponse.statusCode == 204;
            } catch (_) {
              uploadSuccess = false;
            }
          }
        }
      }

      if (!uploadSuccess) {
        return const Left(ServerFailure('Failed to upload one or more photos'));
      }
    }
    return const Right(null);
  }
}
