import '../../../data/models/policy_model.dart';

abstract class PolicyState {}

class PolicyInitial extends PolicyState {}

class PolicyLoading extends PolicyState {}

class PolicySuccess extends PolicyState {
  final PolicyModel policy;
  PolicySuccess(this.policy);
}

class PolicyFailure extends PolicyState {
  final String message;
  PolicyFailure(this.message);
}
