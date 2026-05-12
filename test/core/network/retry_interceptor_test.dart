import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strengthlabs/core/network/retry_interceptor.dart';

void main() {
  group('RetryInterceptor', () {
    test('retries a GET that fails with a connection error', () async {
      var attempts = 0;
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      dio.httpClientAdapter = _FlakyAdapter(
        failuresBeforeSuccess: 2,
        body: '"ok"',
        onAttempt: () => attempts++,
      );
      dio.interceptors.add(RetryInterceptor(
        dio: dio,
        maxRetries: 3,
        // Make backoff effectively instant in tests.
        initialDelay: Duration.zero,
      ));

      final response = await dio.get('/anything');
      expect(response.data, 'ok');
      expect(attempts, 3); // 2 failures + 1 success
    });

    test('retries on 502/503/504 statuses', () async {
      var attempts = 0;
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      dio.httpClientAdapter = _FlakyAdapter(
        failuresBeforeSuccess: 0,
        statusCodeSequence: [503, 502, 200],
        body: '"recovered"',
        onAttempt: () => attempts++,
      );
      dio.interceptors.add(RetryInterceptor(
        dio: dio,
        maxRetries: 5,
        initialDelay: Duration.zero,
      ));

      final response = await dio.get('/x');
      expect(response.data, 'recovered');
      expect(attempts, 3);
    });

    test('does NOT retry POST / PUT / DELETE — mutations go via SyncQueue', () async {
      var attempts = 0;
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      dio.httpClientAdapter = _FlakyAdapter(
        failuresBeforeSuccess: 5,
        body: '"never reached"',
        onAttempt: () => attempts++,
      );
      dio.interceptors.add(RetryInterceptor(
        dio: dio,
        maxRetries: 3,
        initialDelay: Duration.zero,
      ));

      await expectLater(
        dio.post('/x'),
        throwsA(isA<DioException>()),
      );
      expect(attempts, 1, reason: 'POST must not be retried');
    });

    test('does NOT retry on 4xx (client error is permanent)', () async {
      var attempts = 0;
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      dio.httpClientAdapter = _FlakyAdapter(
        failuresBeforeSuccess: 0,
        statusCodeSequence: [400],
        body: '{"error":"bad"}',
        onAttempt: () => attempts++,
      );
      dio.interceptors.add(RetryInterceptor(
        dio: dio,
        maxRetries: 3,
        initialDelay: Duration.zero,
      ));

      await expectLater(dio.get('/x'), throwsA(isA<DioException>()));
      expect(attempts, 1);
    });

    test('gives up after maxRetries', () async {
      var attempts = 0;
      final dio = Dio(BaseOptions(baseUrl: 'http://test'));
      dio.httpClientAdapter = _FlakyAdapter(
        failuresBeforeSuccess: 10,
        body: '',
        onAttempt: () => attempts++,
      );
      dio.interceptors.add(RetryInterceptor(
        dio: dio,
        maxRetries: 2,
        initialDelay: Duration.zero,
      ));

      await expectLater(dio.get('/x'), throwsA(isA<DioException>()));
      // 1 initial attempt + 2 retries = 3 total
      expect(attempts, 3);
    });
  });
}

/// Test adapter that fails the first N attempts then succeeds, or returns
/// a scripted sequence of status codes.
class _FlakyAdapter implements HttpClientAdapter {
  _FlakyAdapter({
    this.failuresBeforeSuccess = 0,
    this.statusCodeSequence,
    this.body = '',
    this.onAttempt,
  });

  int failuresBeforeSuccess;
  final List<int>? statusCodeSequence;
  final String body;
  final void Function()? onAttempt;
  int _calls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    onAttempt?.call();
    final attemptIndex = _calls++;

    if (statusCodeSequence != null) {
      final code = statusCodeSequence![attemptIndex.clamp(0, statusCodeSequence!.length - 1)];
      return ResponseBody.fromString(body, code, headers: {
        Headers.contentTypeHeader: ['application/json'],
      });
    }

    if (attemptIndex < failuresBeforeSuccess) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    return ResponseBody.fromString(body, 200, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }
}
