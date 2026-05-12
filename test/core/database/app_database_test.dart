import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:strengthlabs/core/database/app_database.dart';

void main() {
  setUpAll(_loadSqlite3OnLinux);

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('inserts and reads a workout row', () async {
    final row = WorkoutsTableCompanion.insert(
      id: 'w1',
      clientRequestId: 'crid-1',
      name: 'Push',
      date: DateTime.utc(2026, 5, 12),
      durationSeconds: 3600,
      localUpdatedAt: DateTime.utc(2026, 5, 12, 10),
    );
    await db.into(db.workoutsTable).insert(row);

    final fetched = await db.select(db.workoutsTable).get();
    expect(fetched.length, 1);
    expect(fetched.first.name, 'Push');
    expect(fetched.first.syncState, 'synced');
    expect(fetched.first.version, 0);
  });

  test('client_request_id is unique', () async {
    final base = WorkoutsTableCompanion.insert(
      id: 'w1',
      clientRequestId: 'dup',
      name: 'a',
      date: DateTime.utc(2026, 5, 12),
      durationSeconds: 60,
      localUpdatedAt: DateTime.utc(2026, 5, 12),
    );
    await db.into(db.workoutsTable).insert(base);

    final duplicate = WorkoutsTableCompanion.insert(
      id: 'w2',
      clientRequestId: 'dup',
      name: 'b',
      date: DateTime.utc(2026, 5, 12),
      durationSeconds: 60,
      localUpdatedAt: DateTime.utc(2026, 5, 12),
    );
    await expectLater(
      db.into(db.workoutsTable).insert(duplicate),
      throwsA(anything),
    );
  });

  test('sync queue rows enqueue in insertion order', () async {
    await db.into(db.syncQueueTable).insert(SyncQueueTableCompanion.insert(
          op: 'createWorkout',
          entityId: 'w1',
          payloadJson: '{}',
          nextRetryAt: DateTime.utc(2026, 5, 12),
          createdAt: DateTime.utc(2026, 5, 12, 10),
        ));
    await db.into(db.syncQueueTable).insert(SyncQueueTableCompanion.insert(
          op: 'updateWorkout',
          entityId: 'w1',
          payloadJson: '{}',
          nextRetryAt: DateTime.utc(2026, 5, 12),
          createdAt: DateTime.utc(2026, 5, 12, 11),
        ));

    final rows = await (db.select(db.syncQueueTable)
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
    expect(rows.length, 2);
    expect(rows.first.op, 'createWorkout');
    expect(rows.last.op, 'updateWorkout');
  });

  test('cached_user upserts to a single row by explicit id', () async {
    await db.into(db.cachedUserTable).insert(
        CachedUserTableCompanion.insert(
          id: const Value(1),
          userId: 'u1',
          name: 'A',
          email: 'a@x.com',
          cachedAt: DateTime.utc(2026, 5, 12),
        ),
        mode: InsertMode.insertOrReplace);

    await db.into(db.cachedUserTable).insert(
        CachedUserTableCompanion.insert(
          id: const Value(1),
          userId: 'u2',
          name: 'B',
          email: 'b@x.com',
          cachedAt: DateTime.utc(2026, 5, 12),
        ),
        mode: InsertMode.insertOrReplace);

    final rows = await db.select(db.cachedUserTable).get();
    expect(rows.length, 1);
    expect(rows.first.userId, 'u2');
  });

  test('watch emits when a workout is inserted', () async {
    final stream = db.select(db.workoutsTable).watch();
    final emissions = <List<WorkoutRow>>[];
    final sub = stream.listen(emissions.add);

    await db.into(db.workoutsTable).insert(WorkoutsTableCompanion.insert(
          id: 'w1',
          clientRequestId: 'c1',
          name: 'x',
          date: DateTime.utc(2026, 5, 12),
          durationSeconds: 60,
          localUpdatedAt: DateTime.utc(2026, 5, 12),
        ));

    // Allow the stream to pulse.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(emissions.last.length, 1);
    await sub.cancel();
  });
}

/// Fedora ships `libsqlite3.so.0` but not `libsqlite3.so` (without suffix), so
/// `package:sqlite3` can't find it through its default loader during VM
/// tests. Point it at the versioned filename when running on Linux.
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
