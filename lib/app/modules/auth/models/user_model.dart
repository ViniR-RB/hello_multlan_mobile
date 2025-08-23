import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum Role {
  // ignore: constant_identifier_names
  INTERNAL,
  // ignore: constant_identifier_names
  EXTERNAL,
}

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;

  @JsonKey(unknownEnumValue: Role.INTERNAL)
  final Role role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJsonMap() => _$UserModelToJson(this);

  String toJson() => jsonEncode(toJsonMap());
}
