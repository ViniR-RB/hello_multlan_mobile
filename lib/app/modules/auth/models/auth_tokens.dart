import 'package:json_annotation/json_annotation.dart';

part 'auth_tokens.g.dart';

@JsonSerializable()
class AuthTokens {
  final String accessToken;
  final String refreshToken;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}
