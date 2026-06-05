import 'package:aqua_go/features/complaints/data/models/complaint_model.dart';

abstract class ComplaintsState {}

class ComplaintsInitial extends ComplaintsState {}

class ComplaintsLoading extends ComplaintsState {}

class ComplaintsSuccess extends ComplaintsState {
  final List<ComplaintModel> complaints;
  ComplaintsSuccess(this.complaints);
}

class ComplaintsFailure extends ComplaintsState {
  final String message;
  ComplaintsFailure(this.message);
}

class ComplaintSubmitLoading extends ComplaintsState {}

class ComplaintSubmitSuccess extends ComplaintsState {
  final ComplaintModel complaint;
  ComplaintSubmitSuccess(this.complaint);
}

class ComplaintSubmitFailure extends ComplaintsState {
  final String message;
  ComplaintSubmitFailure(this.message);
}
