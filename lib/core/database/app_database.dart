import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Workouts mirrored from the server plus local-only sync metadata.
///
/// [serverId] is the workout's authoritative id (server UUID). [clientRequestId]
/// is the idempotency key we send to POST /workouts — also used as a stable
/// local key while a row is still `pendingCreate` (when [serverId] is null).
/// [syncState] drives the SyncManager queue.
@DataClassName('WorkoutRow')
class WorkoutsTable extends Table {
  @override
  String get tableName => 'workouts';

  TextColumn get id => text()(); // local primary key — same as serverId when synced
  TextColumn get serverId => text().nullable()();
  TextColumn get clientRequestId => text().unique()();
  TextColumn get name => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get durationSeconds => integer()();
  TextColumn get notes => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(0))();
  TextColumn get exercisesJson => text().withDefault(const Constant('[]'))();
  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))(); // synced | pendingCreate | pendingUpdate | pendingDelete | failed
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Pending operations to replay against the server when connectivity is up.
///
/// Operations are processed FIFO per entity. Each row is keyed by [id] and
/// references the local workout via [entityId] (the workouts.id local key).
@DataClassName('SyncQueueRow')
class SyncQueueTable extends Table {
  @override
  String get tableName => 'sync_queue';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get op => text()(); // createWorkout | updateWorkout | deleteWorkout
  TextColumn get entityId => text()();
  TextColumn get payloadJson => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get nextRetryAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Single-row table caching the authenticated user. Used by AuthRepository
/// to skip /auth/me when the device is offline.
@DataClassName('CachedUserRow')
class CachedUserTable extends Table {
  @override
  String get tableName => 'cached_user';

  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [WorkoutsTable, SyncQueueTable, CachedUserTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'strengthlabs.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
