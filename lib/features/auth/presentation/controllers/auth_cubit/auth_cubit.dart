import 'package:aqua_go/features/auth/data/models/user_model.dart';
import 'package:aqua_go/features/auth/data/repos/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepo;
  AuthCubit(this._authRepo) : super(LoginInitial());

  Future<void> login(String phone) async {
    emit(LoginLoading());
    final result = await _authRepo.login(phone.trim());
    result.fold(
      (failure) => emit(LoginError(failure.message)),
      (otpSessionId) => emit(OtpSent(otpSessionId)),
    );
  }

  Future<void> verifyOtp({
    required String phone,
    required String otpSessionId,
    required String otp,
  }) async {
    emit(LoginLoading());
    final result = await _authRepo.verifyOtp(
      phone: phone.trim(),
      otpSessionId: otpSessionId,
      otp: otp,
    );
    result.fold(
      (failure) => emit(LoginError(failure.message)),
      (user) => emit(LoginSuccess(user)),
    );
  }

  Future<void> requestEmailVerify(String email) async {
    emit(LoginLoading());
    final result = await _authRepo.requestEmailVerify(email);
    result.fold(
      (failure) => emit(LoginError(failure.message)),
      (otpSessionId) => emit(EmailOtpSent(otpSessionId)),
    );
  }

  Future<void> confirmEmailVerify({
    required String email,
    required String otpSessionId,
    required String otp,
  }) async {
    emit(LoginLoading());
    final result = await _authRepo.confirmEmailVerify(
      email: email,
      otpSessionId: otpSessionId,
      otp: otp,
    );
    result.fold(
      (failure) => emit(LoginError(failure.message)),
      (user) => emit(LoginSuccess(user)),
    );
  }

  Future<void> updateProfile(UserModel user) async {
    emit(ProfileUpdateLoading());
    final result = await _authRepo.updateProfile(user);
    result.fold(
      (failure) => emit(ProfileUpdateError(failure.message)),
      (updatedUser) => emit(ProfileUpdateSuccess(updatedUser)),
    );
  }

  Future<void> logout() async {
    emit(LogoutLoading());
    await _authRepo.logout();
    emit(LogoutSuccess());
  }

  Future<void> deleteAccount() async {
    emit(DeleteAccountLoading());
    final result = await _authRepo.deleteAccount();
    result.fold((failure) => emit(DeleteAccountError(failure.message)), (
      _,
    ) async {
      await logout();
      emit(DeleteAccountSuccess());
    });
  }

  Future<void> uploadAvatar(String filePath) async {
    emit(ProfileUpdateLoading());
    final result = await _authRepo.uploadProfileImage(filePath);
    result.fold(
      (failure) => emit(ProfileUpdateError(failure.message)),
      (updatedUser) => emit(ProfileUpdateSuccess(updatedUser)),
    );
  }
}
