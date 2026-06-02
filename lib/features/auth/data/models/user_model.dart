import 'dart:convert';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? imageUrl;
  final String? gender;
  final DateTime? birthdate;

  const UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.imageUrl,
    this.gender,
    this.birthdate,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      imageUrl: map['imageUrl'],
      gender: map['gender'],
      birthdate: map['birthdate'] != null
          ? DateTime.tryParse(map['birthdate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
      'gender': gender,
      'birthdate': birthdate?.toIso8601String(),
    };
  }

  String toEncodedJson() => json.encode(toJson());

  factory UserModel.fromEncodedJson(String source) =>
      UserModel.fromJson(json.decode(source));

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? imageUrl,
    String? gender,
    DateTime? birthdate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    imageUrl,
    gender,
    birthdate,
  ];
}
