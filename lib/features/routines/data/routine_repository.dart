import 'package:strengthlabs_beta/features/routines/data/mock_routines.dart';
import 'package:strengthlabs_beta/features/routines/domain/entities/routine.dart';

class RoutineRepository {
  const RoutineRepository();

  Future<List<Routine>> getRoutines({RoutineLevel? level}) async {
    if (level == null) return kMockRoutines;
    return kMockRoutines.where((r) => r.level == level).toList();
  }

  Future<Routine> getRoutine(String id) async {
    return kMockRoutines.firstWhere(
      (r) => r.id == id,
      orElse: () => throw Exception('Routine not found: $id'),
    );
  }
}
