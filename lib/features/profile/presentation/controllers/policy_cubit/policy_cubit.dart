import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repos/policies_repository.dart';
import 'policy_state.dart';

class PolicyCubit extends Cubit<PolicyState> {
  final PoliciesRepository _repository;

  PolicyCubit(this._repository) : super(PolicyInitial());

  Future<void> fetchPolicy({required String type, required String locale}) async {
    emit(PolicyLoading());
    final result = await _repository.getPolicy(type: type, locale: locale);
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicySuccess(policy)),
    );
  }
}
