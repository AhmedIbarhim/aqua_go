import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_go/core/enums/payment_method_enum.dart';
import '../../../data/repos/tips_repository.dart';
import 'paying_tips_state.dart';

class PayingTipsCubit extends Cubit<PayingTipsState> {
  final TipsRepository _repository;

  PayingTipsCubit(this._repository) : super(PayingTipsInitial());

  Future<void> initiateTipPayment({
    required String bookingId,
    required int amountMinor,
    required PaymentMethod paymentMethod,
  }) async {
    emit(PayingTipsLoading());
    final result = await _repository.initiateTipPayment(
      bookingId: bookingId,
      amountMinor: amountMinor,
      paymentMethod: paymentMethod,
    );
    result.fold(
      (failure) => emit(PayingTipsFailure(failure.message)),
      (paymentInit) => emit(PayingTipsInitSuccess(paymentInit)),
    );
  }

  Future<void> payTip({
    required String bookingId,
    required int amountMinor,
    required PaymentMethod paymentMethod,
    String? moyasarPaymentId,
  }) async {
    emit(PayingTipsLoading());
    final result = await _repository.payTip(
      bookingId: bookingId,
      amountMinor: amountMinor,
      paymentMethod: paymentMethod,
      moyasarPaymentId: moyasarPaymentId,
    );
    result.fold(
      (failure) => emit(PayingTipsFailure(failure.message)),
      (booking) => emit(PayingTipsSuccess(booking)),
    );
  }
}
