import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum Role {
  internal("INTERNAL"),
  admin("ADMIN");

  final String value;
  const Role(this.value);
}

@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String email;

  @JsonKey(unknownEnumValue: Role.internal)
  final Role role;

  final bool isActive;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJsonMap() => _$UserModelToJson(this);

  String toJson() => jsonEncode(toJsonMap());
}
