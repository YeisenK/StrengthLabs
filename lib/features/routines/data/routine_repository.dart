import 'package:strengthlabs/features/routines/data/mock_routines.dart';
import 'package:strengthlabs/features/routines/domain/entities/routine.dart';

/// Frontend-only catalogue. The deployed backend's `/routines` endpoint
/// returns routines with synthetic exercise ids ("ex-barbell-bench-press")
/// that don't exist in the exercises table, so workouts started from
/// backend routines can't be saved. Shipping the catalogue from the app
/// guarantees the listing is populated, the detail has days+exercises, and
/// the "Iniciar rutina" flow can hand a workable template to the active
/// workout cubit.
class RoutineRepository {
  const RoutineRepository();

  Future<List<Routine>> getRoutines({RoutineLevel? level}) async {
    if (level == null) return kMockRoutines;
    return kMockRoutines.where((r) => r.level == level).toList();
  }

  Future<Routine> getRoutine(String id) async {
    return kMockRoutines.firstWhere(
      (r) => r.id == id,
      orElse: () => throw Exception('Routine not found'),
    );
  }
}
