import 'package:drift/drift.dart';
import 'package:strengthlabs/core/database/app_database.dart';
import 'package:strengthlabs/core/sync/sync_manager.dart';
import 'package:strengthlabs/features/workouts/domain/entities/workout.dart';
import 'package:uuid/uuid.dart';

/// Offline-first writes for workouts.
///
/// `createWorkout` returns immediately after persisting to the local Drift
/// database and enqueuing a network operation — the caller doesn't wait for
/// the server. When connectivity is up, [SyncManager.processPending] drains
/// the queue and updates each local row with the server id + version.
///
/// Reads go through `watchWorkouts` which exposes Drift's reactive stream,
/// so the UI updates as soon as a sync attempt resolves.
class OfflineWorkoutService {
  OfflineWorkoutService({
    required this.db,
    required this.sync,
    Uuid? uuid,
    DateTime Function()? now,
  })  : _uuid = uuid ?? const Uuid(),
        _now = now ?? DateTime.now;

  final AppDatabase db;
  final SyncManager sync;
  final Uuid _uuid;
  final DateTime Function() _now;

  /// Persist a new workout locally and enqueue its upload.
  ///
  /// The returned [LocalWorkoutHandle] gives the caller a stable local id and
  /// the generated client_request_id (for surfacing in logs / retry UI).
  Future<LocalWorkoutHandle> createWorkout(Workout draft) async {
    final localId = _uuid.v4();
    final clientRequestId = _uuid.v4();
    final payload = {
      'name': draft.name,
      'date': draft.date.toUtc().toIso8601String(),
      'duration_seconds': draft.duration.inSeconds,
      'notes': draft.notes,
      'client_request_id': clientRequestId,
      'exercises': draft.exercises.asMap().entries.map((entry) {
        final i = entry.key;
        final we = entry.value;
        return {
          'exercise_id': we.exercise.id,
          'order': i,
          'sets': we.sets.asMap().entries.map((setEntry) {
            final s = setEntry.value;
            return {
              'weight': s.weight,
              'reps': s.reps,
              'rpe': s.rpe,
              'order': setEntry.key,
            };
          }).toList(),
        };
      }).toList(),
    };

    await db.transaction(() async {
      await db.into(db.workoutsTable).insert(WorkoutsTableCompanion.insert(
            id: localId,
            clientRequestId: clientRequestId,
            name: draft.name,
            date: draft.date.toUtc(),
            durationSeconds: draft.duration.inSeconds,
            notes: Value(draft.notes),
            localUpdatedAt: _now(),
            syncState: const Value('pendingCreate'),
          ));
      await sync.enqueue(SyncOp.createWorkout, localId, payload);
    });

    return LocalWorkoutHandle(
      localId: localId,
      clientRequestId: clientRequestId,
    );
  }

  /// Reactive list of all locally-known workouts, newest first. UI binds to
  /// this stream and re-renders whenever any sync resolves.
  Stream<List<WorkoutRow>> watchWorkouts() {
    final q = db.select(db.workoutsTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
      ]);
    return q.watch();
  }

  /// Mark a workout for deletion. If it never made it to the server (still
  /// `pendingCreate`), it's dropped from the local DB immediately and the
  /// pending create is cancelled.
  Future<void> deleteWorkout(String localId) async {
    final row = await (db.select(db.workoutsTable)
          ..where((t) => t.id.equals(localId)))
        .getSingleOrNull();
    if (row == null) return;
    if (row.serverId == null) {
      // Cancel the pending create instead of telling the server about a row
      // it never saw. Also drops the queued create op.
      await db.transaction(() async {
        await (db.delete(db.syncQueueTable)
              ..where((t) =>
                  t.entityId.equals(localId) & t.op.equals(SyncOp.createWorkout)))
            .go();
        await (db.delete(db.workoutsTable)
              ..where((t) => t.id.equals(localId)))
            .go();
      });
      return;
    }
    await db.transaction(() async {
      await (db.update(db.workoutsTable)
            ..where((t) => t.id.equals(localId)))
          .write(WorkoutsTableCompanion(
        syncState: const Value('pendingDelete'),
        localUpdatedAt: Value(_now()),
      ));
      await sync.enqueue(SyncOp.deleteWorkout, localId, {});
    });
  }
}

class LocalWorkoutHandle {
  const LocalWorkoutHandle({
    required this.localId,
    required this.clientRequestId,
  });
  final String localId;
  final String clientRequestId;
}
