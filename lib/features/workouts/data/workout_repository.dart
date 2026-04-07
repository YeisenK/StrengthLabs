import 'package:strengthlabs_beta/core/constants/api_constants.dart';
import 'package:strengthlabs_beta/core/network/dio_client.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout_set.dart';

class WorkoutRepository {
  const WorkoutRepository(this._client);

  final DioClient _client;

  // ── Workouts ───────────────────────────────────────────────────────────────

  Future<List<Workout>> getWorkouts({int page = 1, int perPage = 50}) async {
    final resp = await _client.dio.get(
      ApiConstants.workouts,
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final items = resp.data['items'] as List;
    return items.map((j) => _workoutFrom(j as Map<String, dynamic>)).toList();
  }

  Future<Workout> getWorkout(String id) async {
    final resp = await _client.dio.get(ApiConstants.workoutById(id));
    return _workoutFrom(resp.data as Map<String, dynamic>);
  }

  Future<Workout> createWorkout(Workout workout) async {
    final resp = await _client.dio.post(
      ApiConstants.workouts,
      data: _workoutToApi(workout),
    );
    return _workoutFrom(resp.data as Map<String, dynamic>);
  }

  Future<Workout> updateWorkout(String id, {String? name, String? notes}) async {
    final resp = await _client.dio.put(
      ApiConstants.workoutById(id),
      data: {
        if (name != null) 'name': name,
        if (notes != null) 'notes': notes,
      },
    );
    return _workoutFrom(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteWorkout(String id) =>
      _client.dio.delete(ApiConstants.workoutById(id));

  // ── Exercises ──────────────────────────────────────────────────────────────

  Future<List<Exercise>> getExercises() async {
    final resp = await _client.dio.get(ApiConstants.exercises);
    return (resp.data as List)
        .map((j) => _exerciseFrom(j as Map<String, dynamic>))
        .toList();
  }

  Future<Exercise> createExercise({
    required String name,
    required MuscleGroup muscleGroup,
  }) async {
    final resp = await _client.dio.post(
      ApiConstants.exercises,
      data: {'name': name, 'muscle_group': muscleGroup.name},
    );
    return _exerciseFrom(resp.data as Map<String, dynamic>);
  }

  // ── Mapping: API → entity ──────────────────────────────────────────────────

  Exercise _exerciseFrom(Map<String, dynamic> j) => Exercise(
        id: j['id'] as String,
        name: j['name'] as String,
        muscleGroup: MuscleGroup.values.byName(j['muscle_group'] as String),
        isCustom: j['is_custom'] as bool? ?? false,
      );

  WorkoutSet _setFrom(Map<String, dynamic> j) => WorkoutSet(
        id: j['id'] as String,
        weight: (j['weight'] as num).toDouble(),
        reps: j['reps'] as int,
        rpe: j['rpe'] != null ? (j['rpe'] as num).toDouble() : null,
      );

  WorkoutExercise _workoutExerciseFrom(Map<String, dynamic> j) =>
      WorkoutExercise(
        exercise: _exerciseFrom(j['exercise'] as Map<String, dynamic>),
        sets: (j['sets'] as List)
            .map((s) => _setFrom(s as Map<String, dynamic>))
            .toList(),
      );

  Workout _workoutFrom(Map<String, dynamic> j) => Workout(
        id: j['id'] as String,
        name: j['name'] as String,
        date: DateTime.parse(j['date'] as String),
        duration: Duration(seconds: j['duration_seconds'] as int),
        notes: j['notes'] as String?,
        exercises: (j['exercises'] as List)
            .map((e) => _workoutExerciseFrom(e as Map<String, dynamic>))
            .toList(),
      );

  // ── Mapping: entity → API ──────────────────────────────────────────────────

  Map<String, dynamic> _workoutToApi(Workout w) => {
        'name': w.name,
        'date': w.date.toIso8601String(),
        'duration_seconds': w.duration.inSeconds,
        'notes': w.notes,
        'exercises': w.exercises.asMap().entries.map((e) => {
              'exercise_id': e.value.exercise.id,
              'order': e.key,
              'sets': e.value.sets.asMap().entries.map((s) => {
                    'weight': s.value.weight,
                    'reps': s.value.reps,
                    'rpe': s.value.rpe,
                    'order': s.key,
                  }).toList(),
            }).toList(),
      };
}
