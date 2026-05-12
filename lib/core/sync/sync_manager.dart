import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:strengthlabs/core/database/app_database.dart';

/// Names of the persisted operations. Kept as constants so DB rows are stable
/// across refactors.
class SyncOp {
  SyncOp._();
  static const createWorkout = 'createWorkout';
  static const updateWorkout = 'updateWorkout';
  static const deleteWorkout = 'deleteWorkout';
}

/// Outcome of attempting one queued operation.
enum SyncResult {
  /// The operation succeeded server-side and was removed from the queue.
  done,

  /// The operation failed with a transient error and was scheduled to retry.
  retry,

  /// The operation will never succeed as-is (4xx with no resolution) and was
  /// marked as failed so the user can see and act on it.
  abandoned,
}

/// Drives the offline write-behind queue.
///
/// - Mutations made by the UI are written to the local Drift database first,
///   then enqueued here. Reads always come from Drift, so the UI is
///   instantly consistent even while the network is down.
/// - When connectivity returns, [processPending] drains the queue in FIFO
///   order. Failures retry with exponential backoff up to [maxAttempts].
/// - Retries reuse the same `client_request_id` so the backend deduplicates
///   them as the same logical create.
class SyncManager {
  SyncManager({
    required this.db,
    required this.dio,
    this.maxAttempts = 6,
    this.initialBackoff = const Duration(seconds: 1),
    this.maxBackoff = const Duration(hours: 1),
    DateTime Function()? now,
    Random? random,
  })  : _now = now ?? DateTime.now,
        _random = random ?? Random();

  final AppDatabase db;
  final Dio dio;
  final int maxAttempts;
  final Duration initialBackoff;
  final Duration maxBackoff;
  final DateTime Function() _now;
  final Random _random;

  bool _processing = false;
  final _processed = StreamController<SyncResult>.broadcast();

  /// Emits one event per processed queue row. Tests subscribe to observe
  /// progress without polling the database.
  Stream<SyncResult> get processed => _processed.stream;

  Future<void> close() => _processed.close();

  /// Append a new operation to the back of the queue. Returns immediately —
  /// the actual network call happens when [processPending] runs.
  Future<void> enqueue(
    String op,
    String entityId,
    Map<String, dynamic> payload,
  ) async {
    final now = _now();
    await db.into(db.syncQueueTable).insert(SyncQueueTableCompanion.insert(
          op: op,
          entityId: entityId,
          payloadJson: jsonEncode(payload),
          nextRetryAt: now,
          createdAt: now,
        ));
  }

  /// Drain all ready entries. Re-entrant calls short-circuit so a long
  /// network round-trip can't cause two parallel drains.
  Future<void> processPending() async {
    if (_processing) return;
    _processing = true;
    try {
      while (true) {
        final next = await _peekReady();
        if (next == null) break;
        await _processOne(next);
      }
    } finally {
      _processing = false;
    }
  }

  Future<SyncQueueRow?> _peekReady() async {
    final now = _now();
    final query = db.select(db.syncQueueTable)
      ..where((t) => t.nextRetryAt.isSmallerOrEqualValue(now))
      ..orderBy([(t) => OrderingTerm(expression: t.id)])
      ..limit(1);
    final rows = await query.get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> _processOne(SyncQueueRow row) async {
    try {
      switch (row.op) {
        case SyncOp.createWorkout:
          await _createWorkout(row);
          break;
        case SyncOp.updateWorkout:
          await _updateWorkout(row);
          break;
        case SyncOp.deleteWorkout:
          await _deleteWorkout(row);
          break;
        default:
          throw StateError('unknown sync op: ${row.op}');
      }
      await (db.delete(db.syncQueueTable)..where((t) => t.id.equals(row.id)))
          .go();
      _processed.add(SyncResult.done);
    } on DioException catch (e) {
      if (_isPermanent(e)) {
        await (db.update(db.syncQueueTable)..where((t) => t.id.equals(row.id)))
            .write(SyncQueueTableCompanion(
          lastError: Value(_describe(e)),
          attempts: Value(row.attempts + 1),
          nextRetryAt: Value(_now().add(const Duration(days: 365 * 10))),
        ));
        _processed.add(SyncResult.abandoned);
        return;
      }
      await _scheduleRetry(row, e);
      _processed.add(SyncResult.retry);
    } catch (e) {
      await _scheduleRetry(row, e);
      _processed.add(SyncResult.retry);
    }
  }

  Future<void> _scheduleRetry(SyncQueueRow row, Object error) async {
    final nextAttempt = row.attempts + 1;
    if (nextAttempt >= maxAttempts) {
      await (db.update(db.syncQueueTable)..where((t) => t.id.equals(row.id)))
          .write(SyncQueueTableCompanion(
        lastError: Value(_describe(error)),
        attempts: Value(nextAttempt),
        // Park it far in the future — user has to manually retry from the UI.
        nextRetryAt: Value(_now().add(const Duration(days: 365 * 10))),
      ));
      return;
    }
    final delay = _backoff(nextAttempt);
    await (db.update(db.syncQueueTable)..where((t) => t.id.equals(row.id)))
        .write(SyncQueueTableCompanion(
      lastError: Value(_describe(error)),
      attempts: Value(nextAttempt),
      nextRetryAt: Value(_now().add(delay)),
    ));
  }

  Duration _backoff(int attempt) {
    final baseMs = initialBackoff.inMilliseconds * pow(2, attempt - 1).toInt();
    final cappedMs = baseMs > maxBackoff.inMilliseconds
        ? maxBackoff.inMilliseconds
        : baseMs;
    // Jitter ±25% to avoid synchronised retries.
    final jitter = (_random.nextDouble() - 0.5) * 0.5 * cappedMs;
    return Duration(milliseconds: (cappedMs + jitter).round());
  }

  bool _isPermanent(DioException e) {
    final s = e.response?.statusCode;
    if (s == null) return false;
    // 4xx is the client's fault and won't fix itself, except 408/409/425/429
    // which are transient or retry-recommended.
    return s >= 400 &&
        s < 500 &&
        s != 408 &&
        s != 409 &&
        s != 425 &&
        s != 429;
  }

  String _describe(Object e) {
    if (e is DioException) {
      final s = e.response?.statusCode;
      return s != null ? 'HTTP $s' : e.type.toString();
    }
    return e.toString();
  }

  // ── Operation implementations ───────────────────────────────────────────

  Future<void> _createWorkout(SyncQueueRow row) async {
    final payload = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    final response = await dio.post('/workouts', data: payload);
    final body = response.data as Map<String, dynamic>;
    // Save server id + version back onto the local row.
    final serverId = body['id'] as String;
    final version = (body['version'] as num?)?.toInt() ?? 0;
    await (db.update(db.workoutsTable)
          ..where((t) => t.id.equals(row.entityId)))
        .write(WorkoutsTableCompanion(
      serverId: Value(serverId),
      version: Value(version),
      syncState: const Value('synced'),
      serverUpdatedAt: Value(_now()),
    ));
  }

  Future<void> _updateWorkout(SyncQueueRow row) async {
    final payload = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    final workout = await (db.select(db.workoutsTable)
          ..where((t) => t.id.equals(row.entityId)))
        .getSingleOrNull();
    if (workout?.serverId == null) {
      // The create hasn't synced yet — let it run first. Re-queue ourselves.
      throw const _NotReadyYet();
    }
    final response = await dio.put(
      '/workouts/${workout!.serverId}',
      data: payload,
      options: Options(headers: {'If-Match': workout.version.toString()}),
    );
    final body = response.data as Map<String, dynamic>;
    final version = (body['version'] as num?)?.toInt() ?? workout.version + 1;
    await (db.update(db.workoutsTable)
          ..where((t) => t.id.equals(row.entityId)))
        .write(WorkoutsTableCompanion(
      version: Value(version),
      syncState: const Value('synced'),
      serverUpdatedAt: Value(_now()),
    ));
  }

  Future<void> _deleteWorkout(SyncQueueRow row) async {
    final workout = await (db.select(db.workoutsTable)
          ..where((t) => t.id.equals(row.entityId)))
        .getSingleOrNull();
    if (workout == null) return;
    if (workout.serverId == null) {
      // Never made it to the server — just drop the local row.
      await (db.delete(db.workoutsTable)
            ..where((t) => t.id.equals(row.entityId)))
          .go();
      return;
    }
    await dio.delete('/workouts/${workout.serverId}');
    await (db.delete(db.workoutsTable)..where((t) => t.id.equals(row.entityId)))
        .go();
  }
}

class _NotReadyYet implements Exception {
  const _NotReadyYet();
}
