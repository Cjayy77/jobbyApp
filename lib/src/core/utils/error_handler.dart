class ErrorHandler {
  static String handleError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error?.toString() ?? 'An unknown error occurred';
  }
}
