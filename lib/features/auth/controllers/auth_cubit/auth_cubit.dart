import 'package:aqua_go/features/auth/data/models/user_model.dart';
import 'package:aqua_go/features/auth/data/repos/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;
  AuthCubit(this._authRepo) : super(LoginInitial());

  Future<void> login(String phone) async {
    emit(LoginLoading());
    final result = await _authRepo.login(phone);
    result.fold(
      (failure) => emit(LoginError(failure.message)),
      (_) => emit(OtpSent()),
    );
  }

  Future<void> verifyOtp(UserModel user, String otp) async {
    emit(LoginLoading());
    final result = await _authRepo.verifyOtp(user: user, otp: otp);
    result.fold(
      (failure) => emit(LoginError(failure.message)),
      (user) => emit(LoginSuccess(user)),
    );
  }

  Future<void> verifyEmailOtp(String email, String otp) async {
    emit(LoginLoading());
    final currentUser = _authRepo.getUser();
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(email: email);
      final result = await _authRepo.verifyOtp(user: updatedUser, otp: otp);
      result.fold(
        (failure) => emit(LoginError(failure.message)),
        (user) => emit(LoginSuccess(user)),
      );
    } else {
      emit(const LoginError('User not found'));
    }
  }
}

