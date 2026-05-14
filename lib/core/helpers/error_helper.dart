class ErrorHelper {
  static String cleanError(dynamic error) {
    if (error == null) return 'Unknown error occurred';
    final errorString = error.toString();
    if (errorString.startsWith('Exception: ')) {
      return errorString.substring(11);
    }
    return errorString;
  }
}
