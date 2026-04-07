import 'package:strengthlabs_beta/core/storage/workout_local_storage.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout.dart';

class WorkoutRepository {
  const WorkoutRepository(this._localStorage);

  final WorkoutLocalStorage _localStorage;

  Future<List<Workout>> getWorkouts() => _localStorage.load();

  Future<Workout> createWorkout(Workout workout) async {
    final workouts = await _localStorage.load();
    workouts.add(workout);
    await _localStorage.save(workouts);
    return workout;
  }

  Future<void> deleteWorkout(String id) async {
    final workouts = await _localStorage.load();
    workouts.removeWhere((w) => w.id == id);
    await _localStorage.save(workouts);
  }

  Future<List<Exercise>> getExercises() async => [];
}
