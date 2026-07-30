import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/package_model.dart';
import '../../../data/repos/packages_repository.dart';

part 'package_detail_state.dart';

class PackageDetailCubit extends Cubit<PackageDetailState> {
  final PackagesRepository _packagesRepository;

  PackageDetailCubit({required PackagesRepository packagesRepository})
    : _packagesRepository = packagesRepository,
      super(PackageDetailInitial());

  Future<void> getPackage(String packageId) async {
    emit(PackageDetailLoading());
    final result = await _packagesRepository.fetchPackageById(packageId);
    result.fold(
      (failure) => emit(
        failure.message == 'PACKAGE_NOT_FOUND'
            ? PackageDetailNotFound()
            : PackageDetailError(failure.message),
      ),
      (package) => emit(PackageDetailLoaded(package)),
    );
  }
}
