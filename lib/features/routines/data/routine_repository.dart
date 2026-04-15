import 'package:strengthlabs_beta/core/network/dio_client.dart';
import 'package:strengthlabs_beta/features/routines/domain/entities/routine.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';

class RoutineRepository {
  const RoutineRepository(this._dioClient);

  final DioClient _dioClient;

  Future<List<Routine>> getRoutines({RoutineLevel? level}) async {
    final queryParams = level != null
        ? <String, dynamic>{'level': level.name}
        : <String, dynamic>{};
    final response = await _dioClient.dio.get(
      '/routines',
      queryParameters: queryParams,
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List;
    return items.map((e) => _routineFromApi(e as Map<String, dynamic>)).toList();
  }

  Future<Routine> getRoutine(String id) async {
    final response = await _dioClient.dio.get('/routines/$id');
    return _routineFromApi(response.data as Map<String, dynamic>);
  }

  // ── Parsing ───────────────────────────────────────────────────────────────────

  static Routine _routineFromApi(Map<String, dynamic> m) {
    final days = (m['days'] as List).map((d) {
      final dm = d as Map<String, dynamic>;
      final exercises = (dm['exercises'] as List).map((e) {
        final em = e as Map<String, dynamic>;
        final exMap = em['exercise'] as Map<String, dynamic>;
        return RoutineExercise(
          exercise: Exercise(
            id: exMap['id'] as String,
            name: exMap['name'] as String,
            muscleGroup: _parseMuscleGroup(exMap['muscle_group'] as String? ?? ''),
            isCustom: exMap['is_custom'] as bool? ?? false,
          ),
          sets: (em['sets'] as num?)?.toInt() ?? 3,
          repsScheme: em['reps_scheme'] as String? ?? '',
          notes: em['notes'] as String?,
        );
      }).toList();
      return RoutineDay(name: dm['name'] as String, exercises: exercises);
    }).toList();

    return Routine(
      id: m['id'] as String,
      name: m['name'] as String,
      level: _parseLevel(m['level'] as String? ?? ''),
      goal: _parseGoal(m['goal'] as String? ?? ''),
      daysPerWeek: (m['days_per_week'] as num?)?.toInt() ?? 3,
      description: m['description'] as String? ?? '',
      days: days,
    );
  }

  static RoutineLevel _parseLevel(String level) {
    return RoutineLevel.values.firstWhere(
      (l) => l.name == level,
      orElse: () => RoutineLevel.beginner,
    );
  }

  static RoutineGoal _parseGoal(String goal) {
    switch (goal) {
      case 'strength':
        return RoutineGoal.strength;
      case 'hypertrophy':
        return RoutineGoal.hypertrophy;
      case 'endurance':
        return RoutineGoal.endurance;
      case 'general_fitness':
        return RoutineGoal.generalFitness;
      default:
        return RoutineGoal.strength;
    }
  }

  static MuscleGroup _parseMuscleGroup(String mg) {
    switch (mg.toLowerCase()) {
      case 'chest':
        return MuscleGroup.chest;
      case 'back':
        return MuscleGroup.back;
      case 'shoulders':
        return MuscleGroup.shoulders;
      case 'arms':
      case 'biceps':
      case 'triceps':
      case 'forearms':
        return MuscleGroup.arms;
      case 'legs':
      case 'quads':
      case 'hamstrings':
      case 'glutes':
      case 'calves':
        return MuscleGroup.legs;
      default:
        return MuscleGroup.core;
    }
  }
}
