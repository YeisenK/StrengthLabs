import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

/// Retries idempotent reads on transient failures using exponential backoff.
///
/// Scope is deliberately narrow:
/// - Only `GET` is retried. Mutations (`POST`/`PUT`/`DELETE`) are queued by
///   the offline sync layer and re-issued from there with the same
///   `client_request_id`, so retrying them here would race the queue.
/// - Only transient signals retry: network errors (timeout, no connection)
///   and 5xx in [502, 503, 504]. 4xx and other 5xx are permanent enough that
///   blind retries waste time and don't change the answer.
///
/// Backoff is `initialDelay * 2^attempt` with a small random jitter to avoid
/// thundering-herd reconnects when several requests share an outage.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 250),
    this.maxDelay = const Duration(seconds: 5),
    Random? random,
  }) : _random = random ?? Random();

  static const _attemptKey = 'retry.attempt';
  static const _retryableStatuses = {502, 503, 504};

  /// The Dio instance these requests came from. The retry replays through
  /// the same instance so it picks up the same adapter, base URL, and
  /// auth/correlation-id interceptors that produced the original request.
  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final Random _random;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (!_shouldRetry(err) || options.method.toUpperCase() != 'GET') {
      handler.next(err);
      return;
    }

    final attempt = (options.extra[_attemptKey] as int? ?? 0);
    if (attempt >= maxRetries) {
      handler.next(err);
      return;
    }

    await Future.delayed(_backoff(attempt));

    final retryOptions = options.copyWith(
      extra: {...options.extra, _attemptKey: attempt + 1},
    );

    try {
      final response = await dio.fetch(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }
    final status = err.response?.statusCode;
    return status != null && _retryableStatuses.contains(status);
  }

  Duration _backoff(int attempt) {
    if (initialDelay == Duration.zero) return Duration.zero;
    final base = initialDelay * pow(2, attempt).toInt();
    final capped = base > maxDelay ? maxDelay : base;
    final jitterMs = _random.nextInt(100);
    return capped + Duration(milliseconds: jitterMs);
  }
}
