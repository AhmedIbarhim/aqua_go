import 'package:aqua_go/features/profile/data/repos/profile_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'support_state.dart';

class SupportCubit extends Cubit<SupportState> {
  final ProfileRepository _repository;

  SupportCubit(this._repository) : super(SupportInitial());

  Future<void> getWhatsAppNumber() async {
    emit(SupportLoading());
    final result = await _repository.getWhatsAppNumber();
    result.fold(
      (failure) => emit(SupportFailure(failure.message)),
      (whatsappNumber) => emit(SupportWhatsAppLoaded(whatsappNumber)),
    );
  }
}
