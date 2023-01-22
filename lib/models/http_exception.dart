class HttpException implements Exception {
  final String error;
  HttpException(this.error);

  String message() {
    return error;
  }
}
