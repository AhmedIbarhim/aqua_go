import 'package:equatable/equatable.dart';

class RegisteredDeviceModel extends Equatable {
  final String id;
  final DateTime registeredAt;

  const RegisteredDeviceModel({
    required this.id,
    required this.registeredAt,
  });

  factory RegisteredDeviceModel.fromJson(Map<String, dynamic> json) {
    return RegisteredDeviceModel(
      id: json['id'] as String,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registeredAt': registeredAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, registeredAt];
}
