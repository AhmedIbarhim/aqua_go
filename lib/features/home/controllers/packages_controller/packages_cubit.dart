import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/package_model.dart';
import '../../data/repos/packages_repository.dart';

part 'packages_state.dart';

class PackagesCubit extends Cubit<PackagesState> {
  final PackagesRepository _packagesRepository;

  PackagesCubit({required PackagesRepository packagesRepository})
    : _packagesRepository = packagesRepository,
      super(PackagesInitial());

  Future<void> getPackages() async {
    emit(PackagesLoading());
    final result = await _packagesRepository.fetchPackages();
    result.fold(
      (failure) => emit(PackagesError(failure.message)),
      (packagesList) => emit(PackagesLoaded(List.from(packagesList))),
    );
  }
}
