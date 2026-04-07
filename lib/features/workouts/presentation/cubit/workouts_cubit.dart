import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/core/storage/workout_local_storage.dart';
import 'package:strengthlabs_beta/features/workouts/data/mock_workouts.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/cubit/workouts_state.dart';

class WorkoutsCubit extends Cubit<WorkoutsState> {
  WorkoutsCubit() : super(const WorkoutsInitial());

  final _storage = WorkoutLocalStorage();
  final List<Workout> _workouts = [];

  Future<void> loadWorkouts() async {
    emit(const WorkoutsLoading());
    if (await _storage.isFirstLaunch()) {
      _workouts.addAll(kMockWorkouts);
      await _storage.save(_workouts);
      await _storage.markSeeded();
    } else {
      _workouts
        ..clear()
        ..addAll(await _storage.load());
    }
    _workouts.sort((a, b) => b.date.compareTo(a.date));
    emit(WorkoutsLoaded(List.unmodifiable(_workouts)));
  }

  Future<void> saveWorkout(Workout workout) async {
    _workouts.add(workout);
    _workouts.sort((a, b) => b.date.compareTo(a.date));
    await _storage.save(_workouts);
    emit(WorkoutsLoaded(List.unmodifiable(_workouts)));
  }

  Future<void> deleteWorkout(String id) async {
    _workouts.removeWhere((w) => w.id == id);
    await _storage.save(_workouts);
    emit(WorkoutsLoaded(List.unmodifiable(_workouts)));
  }

  List<Workout> inRange(DateTimeRange range) => _workouts
      .where((w) =>
          !w.date.isBefore(range.start) &&
          !w.date.isAfter(range.end.add(const Duration(days: 1))))
      .toList();

  Workout? findById(String id) {
    try {
      return _workouts.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }
}
