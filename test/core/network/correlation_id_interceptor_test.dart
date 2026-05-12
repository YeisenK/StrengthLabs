import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strengthlabs/core/network/correlation_id_interceptor.dart';

void main() {
  late CorrelationIdInterceptor interceptor;

  setUp(() {
    interceptor = CorrelationIdInterceptor();
  });

  test('adds X-Request-Id when missing', () {
    final options = RequestOptions(path: '/test');
    interceptor.onRequest(options, _NoopHandler());
    final id = options.headers['X-Request-Id'] as String?;
    expect(id, isNotNull);
    expect(id!.length, greaterThan(20));
  });

  test('preserves an existing X-Request-Id', () {
    final options = RequestOptions(path: '/test', headers: {
      'X-Request-Id': 'caller-supplied-id',
    });
    interceptor.onRequest(options, _NoopHandler());
    expect(options.headers['X-Request-Id'], 'caller-supplied-id');
  });

  test('each request gets a unique id', () {
    final ids = <String>{};
    for (var i = 0; i < 50; i++) {
      final options = RequestOptions(path: '/test');
      interceptor.onRequest(options, _NoopHandler());
      ids.add(options.headers['X-Request-Id'] as String);
    }
    expect(ids.length, 50, reason: 'expected 50 distinct ids');
  });
}

class _NoopHandler extends RequestInterceptorHandler {
  @override
  void next(RequestOptions requestOptions) {}
}
