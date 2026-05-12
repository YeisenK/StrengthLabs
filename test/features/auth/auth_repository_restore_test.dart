import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:strengthlabs/core/network/dio_client.dart';
import 'package:strengthlabs/core/storage/token_storage.dart';
import 'package:strengthlabs/features/auth/data/auth_repository.dart';
import 'package:strengthlabs/features/auth/data/session_restore_result.dart';
import 'package:strengthlabs/features/auth/data/user_cache.dart';
import 'package:strengthlabs/features/auth/domain/entities/user.dart';

class _FakeDioClient extends Fake implements DioClient {
  _FakeDioClient(this._dio);
  final Dio _dio;
  @override
  Dio get dio => _dio;
}

class _MockTokenStorage extends Mock implements TokenStorage {}

class _InMemoryUserCache implements UserCache {
  User? _stored;
  @override
  Future<void> save(User user) async => _stored = user;
  @override
  Future<User?> read() async => _stored;
  @override
  Future<void> clear() async => _stored = null;
}

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late _MockTokenStorage tokens;
  late _InMemoryUserCache cache;
  late AuthRepository repo;

  const userJson = {
    'id': 'u1',
    'name': 'Alice',
    'email': 'a@b.com',
  };
  const userEntity = User(id: 'u1', name: 'Alice', email: 'a@b.com');

  setUp(() {
    dio = Dio();
    adapter = DioAdapter();
    dio.httpClientAdapter = adapter;
    tokens = _MockTokenStorage();
    cache = _InMemoryUserCache();
    repo = AuthRepository(
      _FakeDioClient(dio),
      tokens,
      userCache: cache,
    );
  });

  group('restoreSession', () {
    test('returns SessionMissing when no tokens stored', () async {
      when(() => tokens.hasTokens()).thenAnswer((_) async => false);
      expect(await repo.restoreSession(), isA<SessionMissing>());
    });

    test('returns SessionRestored and caches user when /auth/me succeeds', () async {
      when(() => tokens.hasTokens()).thenAnswer((_) async => true);
      adapter.queueResponse('GET', '/auth/me',
          status: 200, body: userJson);
      final result = await repo.restoreSession();
      expect(result, isA<SessionRestored>());
      expect((result as SessionRestored).user, userEntity);
      expect(result.fromCache, false);
      expect(await cache.read(), userEntity);
    });

    test('returns SessionExpired and clears tokens on 401', () async {
      when(() => tokens.hasTokens()).thenAnswer((_) async => true);
      when(() => tokens.clearTokens()).thenAnswer((_) async {});
      adapter.queueResponse('GET', '/auth/me',
          status: 401, body: {'detail': 'expired'});
      final result = await repo.restoreSession();
      expect(result, isA<SessionExpired>());
      verify(() => tokens.clearTokens()).called(1);
    });

    test('returns SessionRestored fromCache on network error when cache exists',
        () async {
      when(() => tokens.hasTokens()).thenAnswer((_) async => true);
      await cache.save(userEntity);
      adapter.queueConnectionError('GET', '/auth/me');
      final result = await repo.restoreSession();
      expect(result, isA<SessionRestored>());
      expect((result as SessionRestored).fromCache, true);
      expect(result.user, userEntity);
      verifyNever(() => tokens.clearTokens());
    });

    test(
        'returns SessionOfflineNoCache on network error when no cache exists',
        () async {
      when(() => tokens.hasTokens()).thenAnswer((_) async => true);
      adapter.queueConnectionError('GET', '/auth/me');
      final result = await repo.restoreSession();
      expect(result, isA<SessionOfflineNoCache>());
      verifyNever(() => tokens.clearTokens());
    });

    test('returns SessionRestored fromCache on 5xx server error if cached',
        () async {
      when(() => tokens.hasTokens()).thenAnswer((_) async => true);
      await cache.save(userEntity);
      adapter.queueResponse('GET', '/auth/me', status: 503, body: {});
      final result = await repo.restoreSession();
      expect(result, isA<SessionRestored>());
      expect((result as SessionRestored).fromCache, true);
      verifyNever(() => tokens.clearTokens());
    });
  });
}

/// Minimal Dio adapter that queues responses or connection errors per path.
class DioAdapter implements HttpClientAdapter {
  final List<_Queued> _queue = [];

  void queueResponse(String method, String path,
      {required int status, required Object body}) {
    _queue.add(_Queued.response(method, path, status, body));
  }

  void queueConnectionError(String method, String path) {
    _queue.add(_Queued.connError(method, path));
  }

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    final idx = _queue.indexWhere((q) =>
        q.method == options.method.toUpperCase() && q.path == options.path);
    if (idx == -1) {
      throw StateError('No queued response for ${options.method} ${options.path}');
    }
    final q = _queue.removeAt(idx);
    if (q.connError) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'simulated offline',
      );
    }
    final json = q.body is String ? q.body as String : _encode(q.body!);
    return ResponseBody.fromString(
      json,
      q.status!,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  String _encode(Object body) {
    // Minimal JSON encode for tests — falls back to toString for non-Map/List.
    return _jsonEncode(body);
  }

  static String _jsonEncode(Object obj) {
    return const _PlainJson().encode(obj);
  }
}

class _Queued {
  _Queued.response(this.method, this.path, this.status, this.body)
      : connError = false;
  _Queued.connError(this.method, this.path)
      : status = null,
        body = null,
        connError = true;
  final String method;
  final String path;
  final int? status;
  final Object? body;
  final bool connError;
}

class _PlainJson {
  const _PlainJson();
  String encode(Object obj) {
    final buffer = StringBuffer();
    _write(buffer, obj);
    return buffer.toString();
  }

  void _write(StringBuffer b, Object? v) {
    if (v == null) {
      b.write('null');
    } else if (v is num || v is bool) {
      b.write(v);
    } else if (v is String) {
      b.write('"${v.replaceAll('"', r'\"')}"');
    } else if (v is List) {
      b.write('[');
      for (var i = 0; i < v.length; i++) {
        if (i > 0) b.write(',');
        _write(b, v[i]);
      }
      b.write(']');
    } else if (v is Map) {
      b.write('{');
      var first = true;
      v.forEach((k, val) {
        if (!first) b.write(',');
        first = false;
        _write(b, k.toString());
        b.write(':');
        _write(b, val);
      });
      b.write('}');
    } else {
      _write(b, v.toString());
    }
  }
}
