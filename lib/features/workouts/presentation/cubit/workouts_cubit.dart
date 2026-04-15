import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/features/workouts/data/workout_repository.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/cubit/workouts_state.dart';

class WorkoutsCubit extends Cubit<WorkoutsState> {
  WorkoutsCubit(this._repository) : super(const WorkoutsInitial());

  final WorkoutRepository _repository;

  // Exercises are loaded alongside workouts and exposed for the exercise picker
  List<Exercise> _exercises = [];
  List<Exercise> get exercises => List.unmodifiable(_exercises);

  Future<void> loadWorkouts() async {
    emit(const WorkoutsLoading());
    try {
      final results = await Future.wait([
        _repository.getWorkouts(),
        _repository.getExercises(),
      ]);
      final workouts = (results[0] as List<Workout>)
        ..sort((a, b) => b.date.compareTo(a.date));
      _exercises = results[1] as List<Exercise>;
      emit(WorkoutsLoaded(List.unmodifiable(workouts)));
    } catch (e) {
      emit(WorkoutsError(e.toString()));
    }
  }

  Future<void> saveWorkout(Workout workout) async {
    try {
      final saved = await _repository.createWorkout(workout);
      final current = state is WorkoutsLoaded
          ? List<Workout>.from((state as WorkoutsLoaded).workouts)
          : <Workout>[];
      current.insert(0, saved);
      emit(WorkoutsLoaded(List.unmodifiable(current)));
    } catch (e) {
      // Re-emit current state so the UI doesn't lose the loaded list
      if (state is WorkoutsLoaded) {
        emit(state);
      }
      rethrow;
    }
  }

  Future<void> deleteWorkout(String id) async {
    try {
      await _repository.deleteWorkout(id);
      if (state is WorkoutsLoaded) {
        final updated = (state as WorkoutsLoaded).workouts
            .where((w) => w.id != id)
            .toList();
        emit(WorkoutsLoaded(List.unmodifiable(updated)));
      }
    } catch (e) {
      // Re-emit so the UI keeps the list visible on error
      if (state is WorkoutsLoaded) emit(state);
      rethrow;
    }
  }

  List<Workout> inRange(DateTimeRange range) {
    if (state is! WorkoutsLoaded) return [];
    return (state as WorkoutsLoaded).workouts
        .where((w) =>
            !w.date.isBefore(range.start) &&
            !w.date.isAfter(range.end.add(const Duration(days: 1))))
        .toList();
  }

  Workout? findById(String id) {
    if (state is! WorkoutsLoaded) return null;
    try {
      return (state as WorkoutsLoaded).workouts.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }
}
