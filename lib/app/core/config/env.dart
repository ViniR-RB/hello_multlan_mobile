import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: ".env", obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'API_URL')
  static final String apiUrl = _Env.apiUrl;
}
