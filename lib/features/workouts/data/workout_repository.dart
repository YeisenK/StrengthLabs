import 'package:strengthlabs_beta/core/demo/demo_mode.dart';
import 'package:strengthlabs_beta/core/network/dio_client.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout_set.dart';

class WorkoutRepository {
  const WorkoutRepository(this._dioClient);

  final DioClient _dioClient;

  Future<List<Workout>> getWorkouts() async {
    if (DemoMode.isActive) return DemoMode.workouts;
    final response = await _dioClient.dio.get('/workouts');
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List;
    return items.map((e) => _workoutFromApi(e as Map<String, dynamic>)).toList();
  }

  Future<Workout> createWorkout(Workout workout) async {
    if (DemoMode.isActive) {
      final saved = Workout(
        id: DemoMode.newId('w'),
        name: workout.name,
        date: workout.date,
        duration: workout.duration,
        exercises: workout.exercises
            .map((we) => WorkoutExercise(
                  exercise: we.exercise,
                  sets: we.sets
                      .map((s) => WorkoutSet(
                            id: DemoMode.newId('s'),
                            weight: s.weight,
                            reps: s.reps,
                            rpe: s.rpe,
                          ))
                      .toList(),
                ))
            .toList(),
        notes: workout.notes,
      );
      DemoMode.addWorkout(saved);
      return saved;
    }
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

  Future<Workout> updateWorkout(
    String id, {
    required String name,
    String? notes,
  }) async {
    if (DemoMode.isActive) {
      final existing = DemoMode.workouts.firstWhere((w) => w.id == id);
      final updated = Workout(
        id: existing.id,
        name: name,
        date: existing.date,
        duration: existing.duration,
        exercises: existing.exercises,
        notes: notes,
      );
      DemoMode.replaceWorkout(id, updated);
      return updated;
    }
    final response = await _dioClient.dio.put(
      '/workouts/$id',
      data: {'name': name, 'notes': notes},
    );
    return _workoutFromApi(response.data as Map<String, dynamic>);
  }

  Future<void> deleteWorkout(String id) async {
    if (DemoMode.isActive) {
      DemoMode.removeWorkout(id);
      return;
    }
    await _dioClient.dio.delete('/workouts/$id');
  }

  Future<Exercise> createExercise(String name, MuscleGroup muscleGroup) async {
    if (DemoMode.isActive) {
      final e = Exercise(
        id: DemoMode.newId('e'),
        name: name,
        muscleGroup: muscleGroup,
        isCustom: true,
      );
      DemoMode.addExercise(e);
      return e;
    }
    final response = await _dioClient.dio.post(
      '/exercises',
      data: {'name': name, 'muscle_group': muscleGroup.name},
    );
    return _exerciseFromApi(response.data as Map<String, dynamic>);
  }

  Future<List<Exercise>> getExercises() async {
    if (DemoMode.isActive) return DemoMode.exercises;
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
