import 'package:strengthlabs_beta/core/constants/api_constants.dart';
import 'package:strengthlabs_beta/core/network/dio_client.dart';
import 'package:strengthlabs_beta/features/routines/domain/entities/routine.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';

class RoutineRepository {
  const RoutineRepository(this._client);

  final DioClient _client;

  Future<List<Routine>> getRoutines({RoutineLevel? level}) async {
    final resp = await _client.dio.get(
      ApiConstants.routines,
      queryParameters: {
        if (level != null) 'level': level.name,
      },
    );
    final items = resp.data['items'] as List;
    return items.map((j) => _routineFrom(j as Map<String, dynamic>)).toList();
  }

  Future<Routine> getRoutine(String id) async {
    final resp = await _client.dio.get(ApiConstants.routineById(id));
    return _routineFrom(resp.data as Map<String, dynamic>);
  }

  // ── Mapping ────────────────────────────────────────────────────────────────

  Routine _routineFrom(Map<String, dynamic> j) => Routine(
        id: j['id'] as String,
        name: j['name'] as String,
        level: _levelFrom(j['level'] as String),
        goal: _goalFrom(j['goal'] as String),
        daysPerWeek: j['days_per_week'] as int,
        description: j['description'] as String,
        days: (j['days'] as List)
            .map((d) => _dayFrom(d as Map<String, dynamic>))
            .toList(),
      );

  RoutineDay _dayFrom(Map<String, dynamic> j) => RoutineDay(
        name: j['name'] as String,
        exercises: (j['exercises'] as List)
            .map((e) => _routineExerciseFrom(e as Map<String, dynamic>))
            .toList(),
      );

  RoutineExercise _routineExerciseFrom(Map<String, dynamic> j) =>
      RoutineExercise(
        exercise: Exercise(
          id: j['exercise']['id'] as String,
          name: j['exercise']['name'] as String,
          muscleGroup:
              MuscleGroup.values.byName(j['exercise']['muscle_group'] as String),
          isCustom: j['exercise']['is_custom'] as bool? ?? false,
        ),
        sets: j['sets'] as int,
        repsScheme: j['reps_scheme'] as String,
        notes: j['notes'] as String?,
      );

  RoutineLevel _levelFrom(String s) => RoutineLevel.values.byName(s);

  RoutineGoal _goalFrom(String s) {
    // backend uses snake_case, Dart enum uses camelCase
    const map = {
      'strength': RoutineGoal.strength,
      'hypertrophy': RoutineGoal.hypertrophy,
      'endurance': RoutineGoal.endurance,
      'general_fitness': RoutineGoal.generalFitness,
    };
    return map[s] ?? RoutineGoal.generalFitness;
  }
}
