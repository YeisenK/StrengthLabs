import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout_set.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/cubit/active_workout_state.dart';

class ActiveWorkoutCubit extends Cubit<ActiveWorkoutState> {
  ActiveWorkoutCubit()
      : super(ActiveWorkoutState(
          name: 'Workout',
          startTime: DateTime.now(),
          exercises: const [],
        ));

  int _idCounter = 0;
  String _nextId() => '${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}';

  void setName(String name) => emit(state.copyWith(name: name));

  void addExercise(Exercise exercise) {
    final newExercise = ActiveExercise(
      id: _nextId(),
      exercise: exercise,
      sets: [ActiveSet(id: _nextId())],
    );
    emit(state.copyWith(exercises: [...state.exercises, newExercise]));
  }

  void removeExercise(String exerciseId) {
    emit(state.copyWith(
      exercises: state.exercises.where((e) => e.id != exerciseId).toList(),
    ));
  }

  void addSet(String exerciseId) {
    emit(state.copyWith(
      exercises: state.exercises.map((e) {
        if (e.id != exerciseId) return e;
        return e.copyWith(sets: [...e.sets, ActiveSet(id: _nextId())]);
      }).toList(),
    ));
  }

  void removeSet(String exerciseId, String setId) {
    emit(state.copyWith(
      exercises: state.exercises.map((e) {
        if (e.id != exerciseId) return e;
        final updated = e.sets.where((s) => s.id != setId).toList();
        return e.copyWith(sets: updated.isEmpty ? [ActiveSet(id: _nextId())] : updated);
      }).toList(),
    ));
  }

  void updateSet(
    String exerciseId,
    String setId, {
    String? weight,
    String? reps,
    double? rpe,
    bool? isCompleted,
  }) {
    emit(state.copyWith(
      exercises: state.exercises.map((e) {
        if (e.id != exerciseId) return e;
        return e.copyWith(
          sets: e.sets.map((s) {
            if (s.id != setId) return s;
            return s.copyWith(
              weight: weight,
              reps: reps,
              rpe: rpe,
              isCompleted: isCompleted,
            );
          }).toList(),
        );
      }).toList(),
    ));
  }

  /// Converts the active workout into a [Workout] entity and marks as finished.
  Workout finish() {
    final now = DateTime.now();
    final workoutExercises = state.exercises.map((ae) {
      final validSets = ae.sets
          .where((s) => s.isCompleted && s.weight.isNotEmpty && s.reps.isNotEmpty)
          .map((s) => WorkoutSet(
                id: _nextId(),
                weight: double.tryParse(s.weight) ?? 0,
                reps: int.tryParse(s.reps) ?? 0,
                rpe: s.rpe,
              ))
          .toList();
      return WorkoutExercise(exercise: ae.exercise, sets: validSets);
    }).where((we) => we.sets.isNotEmpty).toList();

    emit(state.copyWith(isFinished: true));

    return Workout(
      id: _nextId(),
      name: state.name,
      date: state.startTime,
      duration: now.difference(state.startTime),
      exercises: workoutExercises,
    );
  }
}
