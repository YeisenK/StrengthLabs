import 'package:dio/dio.dart';

/// Translates raw exceptions thrown by Dio (or anything else) into a
/// user-facing message. Used by cubits to avoid leaking Dart's
/// `Exception: ...` prefix or DioException stack traces into the UI.
String mapApiError(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;

    if (status == 401) return 'Your session has expired. Please log in again.';
    if (status == 403) return "You don't have permission to do that.";
    if (status == 404) return 'The requested item was not found.';
    if (status == 409) return 'This item already exists.';
    if (status == 429) {
      final retryAfter = error.response?.headers.value('retry-after');
      return retryAfter != null
          ? 'Too many requests. Try again in $retryAfter seconds.'
          : 'Too many requests. Please slow down.';
    }
    if (status == 400 || status == 422) {
      return 'Some fields are invalid. Please check and try again.';
    }
    if (status != null && status >= 500) {
      return 'The server is having trouble. Please try again in a moment.';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'No connection — please check your internet';
    }
  }

  // Strip the leading "Exception: " from manually-thrown errors.
  return error.toString().replaceFirst('Exception: ', '');
}
