import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/banner_model.dart';
import '../../data/repos/banners_repository.dart';

part 'banners_state.dart';

class BannersCubit extends Cubit<BannersState> {
  final BannersRepository _bannersRepository;

  BannersCubit({required BannersRepository bannersRepository})
    : _bannersRepository = bannersRepository,
      super(BannersInitial());

  Future<void> getBanners() async {
    emit(BannersLoading());
    final result = await _bannersRepository.fetchBanners();
    result.fold(
      (failure) => emit(BannersError(failure.message)),
      (bannersList) => emit(BannersLoaded(List.from(bannersList))),
    );
  }
}
