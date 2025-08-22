class AppException implements Exception {
  final String code;
  String? message;
  StackTrace? stackTrace;

  AppException(this.code, [this.message, this.stackTrace]);
}
