part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class LoginInitial extends AuthState {}

final class LoginLoading extends AuthState {}

final class LoginSuccess extends AuthState {
  final UserModel user;
  const LoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

final class LoginError extends AuthState {
  final String message;
  const LoginError(this.message);

  @override
  List<Object?> get props => [message];
}

final class OtpSent extends AuthState {
  final String otpSessionId;
  const OtpSent(this.otpSessionId);

  @override
  List<Object?> get props => [otpSessionId];
}

final class EmailOtpSent extends AuthState {
  final String otpSessionId;
  const EmailOtpSent(this.otpSessionId);

  @override
  List<Object?> get props => [otpSessionId];
}

final class ProfileUpdateLoading extends AuthState {}

final class ProfileUpdateSuccess extends AuthState {
  final UserModel user;
  const ProfileUpdateSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

final class ProfileUpdateError extends AuthState {
  final String message;
  const ProfileUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

final class LogoutLoading extends AuthState {}

final class LogoutSuccess extends AuthState {}


