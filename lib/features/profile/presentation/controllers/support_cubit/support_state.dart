part of 'support_cubit.dart';

sealed class SupportState extends Equatable {
  const SupportState();

  @override
  List<Object?> get props => [];
}

final class SupportInitial extends SupportState {}

final class SupportLoading extends SupportState {}

final class SupportWhatsAppLoaded extends SupportState {
  final String whatsappNumber;
  const SupportWhatsAppLoaded(this.whatsappNumber);

  @override
  List<Object?> get props => [whatsappNumber];
}

final class SupportFailure extends SupportState {
  final String message;
  const SupportFailure(this.message);

  @override
  List<Object?> get props => [message];
}
