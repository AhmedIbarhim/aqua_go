import 'dart:convert';

class UserModel {
  final String? name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? gender;
  final DateTime? birthdate;

  UserModel({
    this.name,
    this.email,
    this.phone,
    this.avatar,
    this.gender,
    this.birthdate,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      avatar: map['avatar'],
      gender: map['gender'],
      birthdate: map['birthdate'] != null
          ? DateTime.parse(map['birthdate'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'gender': gender,
      'birthdate': birthdate?.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? gender,
    DateTime? birthdate,
  }) {
    return UserModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
    );
  }
}

