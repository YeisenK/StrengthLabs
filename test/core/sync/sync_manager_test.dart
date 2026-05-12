import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:strengthlabs/core/database/app_database.dart';
import 'package:strengthlabs/core/sync/sync_manager.dart';

void main() {
  setUpAll(_loadSqlite3OnLinux);

  late AppDatabase db;
  late Dio dio;
  late _ScriptedAdapter adapter;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dio = Dio(BaseOptions(baseUrl: 'http://test'));
    adapter = _ScriptedAdapter();
    dio.httpClientAdapter = adapter;
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertLocalWorkout(String id, String clientReqId) {
    return db.into(db.workoutsTable).insert(WorkoutsTableCompanion.insert(
          id: id,
          clientRequestId: clientReqId,
          name: 'New workout',
          date: DateTime.utc(2026, 5, 12),
          durationSeconds: 60,
          localUpdatedAt: DateTime.utc(2026, 5, 12),
          syncState: const Value('pendingCreate'),
        ));
  }

  test('enqueue stores a queue row', () async {
    final mgr = SyncManager(db: db, dio: dio);
    await insertLocalWorkout('local-1', 'crid-1');
    await mgr.enqueue(SyncOp.createWorkout, 'local-1', {'name': 'x'});

    final rows = await db.select(db.syncQueueTable).get();
    expect(rows.length, 1);
    expect(rows.first.op, SyncOp.createWorkout);
    expect(rows.first.entityId, 'local-1');
  });

  test('processPending creates workout on server and removes the queue row',
      () async {
    final mgr = SyncManager(db: db, dio: dio);
    await insertLocalWorkout('local-1', 'crid-1');
    await mgr.enqueue(SyncOp.createWorkout, 'local-1', {
      'name': 'Push',
      'date': '2026-05-12T00:00:00Z',
      'duration_seconds': 60,
      'client_request_id': 'crid-1',
      'exercises': const [],
    });

    adapter.enqueueResponse(
      method: 'POST',
      path: '/workouts',
      status: 201,
      body: {'id': 'server-uuid', 'version': 0},
    );

    await mgr.processPending();

    final queueRows = await db.select(db.syncQueueTable).get();
    expect(queueRows, isEmpty);

    final workout = await (db.select(db.workoutsTable)
          ..where((t) => t.id.equals('local-1')))
        .getSingle();
    expect(workout.serverId, 'server-uuid');
    expect(workout.syncState, 'synced');
  });

  test('transient failure increments attempts and schedules a retry', () async {
    final times = _ClockSequence([
      DateTime.utc(2026, 5, 12, 10),
      DateTime.utc(2026, 5, 12, 10),
      DateTime.utc(2026, 5, 12, 10),
    ]);
    final mgr = SyncManager(
      db: db,
      dio: dio,
      now: times.next,
      initialBackoff: const Duration(seconds: 1),
    );
    await insertLocalWorkout('local-1', 'crid-1');
    await mgr.enqueue(SyncOp.createWorkout, 'local-1', {'name': 'x'});

    adapter.enqueueResponse(
      method: 'POST',
      path: '/workouts',
      status: 503,
      body: {'error': 'down'},
    );

    await mgr.processPending();

    final queueRows = await db.select(db.syncQueueTable).get();
    expect(queueRows.length, 1);
    expect(queueRows.first.attempts, 1);
    expect(queueRows.first.nextRetryAt.isAfter(DateTime.utc(2026, 5, 12, 10)),
        true);
  });

  test('does not re-attempt before nextRetryAt', () async {
    final mgr = SyncManager(
      db: db,
      dio: dio,
      now: () => DateTime.utc(2026, 5, 12, 10),
    );

    // Manually insert a row with retry-time in the future.
    await db.into(db.syncQueueTable).insert(SyncQueueTableCompanion.insert(
          op: SyncOp.createWorkout,
          entityId: 'local-1',
          payloadJson: '{}',
          nextRetryAt: DateTime.utc(2026, 5, 12, 11), // 1h in future
          createdAt: DateTime.utc(2026, 5, 12, 9),
          attempts: const Value(1),
        ));

    await mgr.processPending();

    final rows = await db.select(db.syncQueueTable).get();
    expect(rows.length, 1); // still there
    expect(rows.first.attempts, 1); // not bumped
    verifyZeroRequestsMade(adapter);
  });

  test('permanent error (4xx) abandons the row', () async {
    final mgr = SyncManager(db: db, dio: dio);
    await insertLocalWorkout('local-1', 'crid-1');
    await mgr.enqueue(SyncOp.createWorkout, 'local-1', {'name': 'x'});

    adapter.enqueueResponse(
      method: 'POST',
      path: '/workouts',
      status: 400,
      body: {'error': 'bad input'},
    );

    final results = <SyncResult>[];
    final sub = mgr.processed.listen(results.add);
    await mgr.processPending();
    await sub.cancel();
    await mgr.close();

    expect(results, [SyncResult.abandoned]);
    final rows = await db.select(db.syncQueueTable).get();
    expect(rows.first.attempts, 1);
  });

  test('FIFO order — earlier op is attempted first', () async {
    final mgr = SyncManager(db: db, dio: dio);

    await insertLocalWorkout('local-1', 'crid-1');
    await insertLocalWorkout('local-2', 'crid-2');
    await mgr.enqueue(SyncOp.createWorkout, 'local-1', {
      'name': 'A',
      'client_request_id': 'crid-1',
      'date': '2026-05-12T00:00:00Z',
      'duration_seconds': 0,
      'exercises': const [],
    });
    await mgr.enqueue(SyncOp.createWorkout, 'local-2', {
      'name': 'B',
      'client_request_id': 'crid-2',
      'date': '2026-05-12T00:00:00Z',
      'duration_seconds': 0,
      'exercises': const [],
    });

    adapter.enqueueResponse(
      method: 'POST',
      path: '/workouts',
      status: 201,
      body: {'id': 'srv-1', 'version': 0},
    );
    adapter.enqueueResponse(
      method: 'POST',
      path: '/workouts',
      status: 201,
      body: {'id': 'srv-2', 'version': 0},
    );

    await mgr.processPending();

    final w1 = await (db.select(db.workoutsTable)
          ..where((t) => t.id.equals('local-1')))
        .getSingle();
    final w2 = await (db.select(db.workoutsTable)
          ..where((t) => t.id.equals('local-2')))
        .getSingle();
    expect(w1.serverId, 'srv-1');
    expect(w2.serverId, 'srv-2');
  });
}

void verifyZeroRequestsMade(_ScriptedAdapter a) {
  expect(a.requestCount, 0);
}

class _ClockSequence {
  _ClockSequence(this.values);
  final List<DateTime> values;
  int _i = 0;
  DateTime next() {
    final v = values[_i.clamp(0, values.length - 1)];
    _i++;
    return v;
  }
}

class _ScriptedAdapter implements HttpClientAdapter {
  final List<_Scripted> _queue = [];
  int requestCount = 0;

  void enqueueResponse({
    required String method,
    required String path,
    required int status,
    required Object body,
  }) =>
      _queue.add(_Scripted(method, path, status, body));

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    requestCount++;
    if (_queue.isEmpty) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'no scripted response',
      );
    }
    final s = _queue.removeAt(0);
    return ResponseBody.fromString(_encode(s.body), s.status, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  String _encode(Object body) {
    if (body is String) return body;
    if (body is Map) {
      return '{${body.entries.map((e) => '"${e.key}":${_jsonValue(e.value)}').join(',')}}';
    }
    return body.toString();
  }

  String _jsonValue(Object? v) {
    if (v == null) return 'null';
    if (v is num || v is bool) return v.toString();
    return '"$v"';
  }
}

class _Scripted {
  _Scripted(this.method, this.path, this.status, this.body);
  final String method;
  final String path;
  final int status;
  final Object body;
}

void _loadSqlite3OnLinux() {
  if (!Platform.isLinux) return;
  open.overrideFor(OperatingSystem.linux, () {
    for (final candidate in [
      '/usr/lib64/libsqlite3.so.0',
      '/usr/lib/libsqlite3.so.0',
      '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
    ]) {
      if (File(candidate).existsSync()) {
        return DynamicLibrary.open(candidate);
      }
    }
    return DynamicLibrary.open('libsqlite3.so.0');
  });
}
