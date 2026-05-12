import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:strengthlabs/core/database/app_database.dart';
import 'package:strengthlabs/core/sync/sync_manager.dart';
import 'package:strengthlabs/features/workouts/data/offline_workout_service.dart';
import 'package:strengthlabs/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs/features/workouts/domain/entities/workout.dart';
import 'package:strengthlabs/features/workouts/domain/entities/workout_set.dart';

void main() {
  setUpAll(_loadSqlite3OnLinux);

  late AppDatabase db;
  late Dio dio;
  late _ScriptedAdapter adapter;
  late SyncManager sync;
  late OfflineWorkoutService service;

  final draft = Workout(
    id: 'draft',
    name: 'Push Day',
    date: DateTime.utc(2026, 5, 12, 10),
    duration: const Duration(seconds: 3600),
    exercises: const [
      WorkoutExercise(
        exercise: Exercise(
          id: 'e1',
          name: 'Bench Press',
          muscleGroup: MuscleGroup.chest,
        ),
        sets: [
          WorkoutSet(id: 's1', weight: 60, reps: 8, isCompleted: true),
        ],
      ),
    ],
  );

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dio = Dio(BaseOptions(baseUrl: 'http://test'));
    adapter = _ScriptedAdapter();
    dio.httpClientAdapter = adapter;
    sync = SyncManager(db: db, dio: dio);
    service = OfflineWorkoutService(db: db, sync: sync);
  });

  tearDown(() async {
    await sync.close();
    await db.close();
  });

  test('createWorkout writes locally + enqueues without hitting network',
      () async {
    final handle = await service.createWorkout(draft);

    final rows = await db.select(db.workoutsTable).get();
    expect(rows.length, 1);
    expect(rows.first.id, handle.localId);
    expect(rows.first.syncState, 'pendingCreate');
    expect(rows.first.clientRequestId, handle.clientRequestId);

    final queue = await db.select(db.syncQueueTable).get();
    expect(queue.length, 1);
    expect(queue.first.op, SyncOp.createWorkout);

    expect(adapter.requestCount, 0,
        reason: 'create should not call the network in offline-first path');
  });

  test('processPending uploads, then row becomes synced with server id',
      () async {
    final handle = await service.createWorkout(draft);

    adapter.enqueueResponse(
      method: 'POST',
      path: '/workouts',
      status: 201,
      body: {'id': 'server-uuid', 'version': 0},
    );

    await sync.processPending();

    final row = await (db.select(db.workoutsTable)
          ..where((t) => t.id.equals(handle.localId)))
        .getSingle();
    expect(row.syncState, 'synced');
    expect(row.serverId, 'server-uuid');

    final queue = await db.select(db.syncQueueTable).get();
    expect(queue, isEmpty);
  });

  test('retrying a failed create reuses the same client_request_id', () async {
    final handle = await service.createWorkout(draft);

    // First attempt: server is unreachable.
    adapter.enqueueResponse(
      method: 'POST',
      path: '/workouts',
      status: 503,
      body: {'error': 'down'},
    );
    await sync.processPending();
    final firstReq = adapter.lastBody;
    final firstCrid = firstReq!['client_request_id'] as String;

    // Move retry-time backwards so the next processPending picks it up.
    await db.update(db.syncQueueTable).write(SyncQueueTableCompanion(
          nextRetryAt: Value(DateTime.utc(2020, 1, 1)),
        ));

    // Second attempt: server accepts.
    adapter.enqueueResponse(
      method: 'POST',
      path: '/workouts',
      status: 201,
      body: {'id': 'server-uuid', 'version': 0},
    );
    await sync.processPending();
    final secondReq = adapter.lastBody;
    final secondCrid = secondReq!['client_request_id'] as String;

    expect(firstCrid, secondCrid, reason: 'idempotency key must persist');
    expect(secondCrid, handle.clientRequestId);
  });

  test('deleting a never-synced workout drops the queue entry and local row',
      () async {
    final handle = await service.createWorkout(draft);
    await service.deleteWorkout(handle.localId);

    final rows = await db.select(db.workoutsTable).get();
    expect(rows, isEmpty);
    final queue = await db.select(db.syncQueueTable).get();
    expect(queue, isEmpty,
        reason: 'pending create + delete cancel each other out');
  });

  test('watchWorkouts emits updates as rows change', () async {
    final emissions = <List<WorkoutRow>>[];
    final sub = service.watchWorkouts().listen(emissions.add);

    await service.createWorkout(draft);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(emissions.isNotEmpty, true);
    expect(emissions.last.length, 1);
    await sub.cancel();
  });
}

class _ScriptedAdapter implements HttpClientAdapter {
  final List<_Scripted> _queue = [];
  int requestCount = 0;
  Map<String, dynamic>? lastBody;

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
    lastBody = options.data as Map<String, dynamic>?;
    if (_queue.isEmpty) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
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
