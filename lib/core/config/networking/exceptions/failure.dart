import 'package:equatable/equatable.dart';

export 'server_failure.dart';
export 'status_codes.dart';

enum FailureType {
  network,
  timeout,
  unauthorized,
  forbidden,
  validation,
  notFound,
  server,
  cancelled,
  location,
  unknown,
}

abstract class Failure extends Equatable {
  final String message;
  final FailureType type;

  const Failure(this.message, this.type);

  @override
  List<Object?> get props => [message, type];

  @override
  String toString() {
    return '$runtimeType(message: $message, type: $type)';
  }
}

class LocationFailure extends Failure {
  const LocationFailure(String message) : super(message, FailureType.location);
}
