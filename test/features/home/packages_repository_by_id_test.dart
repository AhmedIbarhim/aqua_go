import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/home/data/data_source/packages_remote_data_source.dart';
import 'package:aqua_go/features/home/data/repos/packages_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hand-written stub: `implements` skips the APIClient constructor, and the
/// private `_apiClient` field is not part of the cross-library interface.
class _StubPackagesDataSource implements PackagesRemoteDataSource {
  _StubPackagesDataSource(this.response);

  final Either<Failure, dynamic> response;

  @override
  Future<Either<Failure, dynamic>> getPackages() async => response;
}

Map<String, dynamic> _packageJson(String id, String nameEn) => {
      'id': id,
      'nameAr': 'باقة',
      'nameEn': nameEn,
      'descriptionAr': 'وصف',
      'descriptionEn': 'description',
      'numWashes': 4,
      'validityDays': 30,
      'priceMinor': 20000,
      'currency': 'SAR',
      'maxActivePerCustomer': 1,
      'allowScheduleLater': true,
      'active': true,
      'bundledServiceIds': <String>[],
      // Bare Asia/Riyadh local ISO-8601 — the only wire shape the backend
      // emits. A `Z` here would teach the next reader a contract that does not
      // exist and hide a device-local parse if these ever become DateTimes.
      'createdAt': '2026-07-01T00:00:00',
      'updatedAt': '2026-07-01T00:00:00',
      'version': 0,
    };

void main() {
  const wantedId = '11111111-1111-1111-1111-111111111111';

  test('fetchPackageById returns the matching package', () async {
    final repo = PackagesRepository(
      _StubPackagesDataSource(
        Right<Failure, dynamic>([
          _packageJson('22222222-2222-2222-2222-222222222222', 'Other'),
          _packageJson(wantedId, 'Wanted'),
        ]),
      ),
    );

    final result = await repo.fetchPackageById(wantedId);

    expect(result.isRight(), isTrue);
    expect(result.getOrElse(() => throw StateError('left')).nameEn, 'Wanted');
  });

  test('fetchPackageById fails when the id is not in the active catalogue', () async {
    final repo = PackagesRepository(
      _StubPackagesDataSource(
        Right<Failure, dynamic>([
          _packageJson('22222222-2222-2222-2222-222222222222', 'Other'),
        ]),
      ),
    );

    final result = await repo.fetchPackageById(wantedId);

    expect(result.isLeft(), isTrue);
    expect(result.fold((f) => f.message, (_) => ''), 'PACKAGE_NOT_FOUND');
  });

  test('fetchPackageById propagates the transport failure', () async {
    final repo = PackagesRepository(
      _StubPackagesDataSource(const Left(ServerFailure('boom'))),
    );

    final result = await repo.fetchPackageById(wantedId);

    expect(result.fold((f) => f.message, (_) => ''), 'boom');
  });
}
