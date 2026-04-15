import 'package:strengthlabs_beta/core/network/dio_client.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout_set.dart';

class WorkoutRepository {
  const WorkoutRepository(this._dioClient);

  final DioClient _dioClient;

  Future<List<Workout>> getWorkouts() async {
    final response = await _dioClient.dio.get('/workouts');
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List;
    return items.map((e) => _workoutFromApi(e as Map<String, dynamic>)).toList();
  }

  Future<Workout> createWorkout(Workout workout) async {
    final data = {
      'name': workout.name,
      'date': workout.date.toUtc().toIso8601String(),
      'duration_seconds': workout.duration.inSeconds,
      'notes': workout.notes,
      'exercises': workout.exercises.asMap().entries.map((entry) {
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

    final response = await _dioClient.dio.post('/workouts', data: data);
    return _workoutFromApi(response.data as Map<String, dynamic>);
  }

  Future<void> deleteWorkout(String id) async {
    await _dioClient.dio.delete('/workouts/$id');
  }

  Future<List<Exercise>> getExercises() async {
    final response = await _dioClient.dio.get('/exercises');
    final items = response.data as List;
    return items
        .map((e) => _exerciseFromApi(e as Map<String, dynamic>))
        .toList();
  }

  // ── Parsing helpers ───────────────────────────────────────────────────────────

  static Workout _workoutFromApi(Map<String, dynamic> json) {
    final exercises = (json['exercises'] as List? ?? []).map((e) {
      final em = e as Map<String, dynamic>;
      final exerciseMap = em['exercise'] as Map<String, dynamic>;
      final sets = (em['sets'] as List? ?? []).map((s) {
        final sm = s as Map<String, dynamic>;
        return WorkoutSet(
          id: sm['id'] as String,
          weight: (sm['weight'] as num?)?.toDouble() ?? 0.0,
          reps: (sm['reps'] as num?)?.toInt() ?? 0,
          rpe: sm['rpe'] != null ? (sm['rpe'] as num).toDouble() : null,
        );
      }).toList();

      return WorkoutExercise(
        exercise: _exerciseFromApi(exerciseMap),
        sets: sets,
      );
    }).toList();

    return Workout(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      duration: Duration(seconds: (json['duration_seconds'] as num?)?.toInt() ?? 0),
      exercises: exercises,
      notes: json['notes'] as String?,
    );
  }

  static Exercise _exerciseFromApi(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      muscleGroup: _parseMuscleGroup(json['muscle_group'] as String? ?? ''),
      isCustom: json['is_custom'] as bool? ?? false,
    );
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
