import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs_beta/core/storage/workout_local_storage.dart';
import 'package:strengthlabs_beta/features/workouts/data/mock_workouts.dart';
import 'package:strengthlabs_beta/features/workouts/data/workout_repository.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout.dart';
import 'package:strengthlabs_beta/features/workouts/presentation/cubit/workouts_state.dart';

class WorkoutsCubit extends Cubit<WorkoutsState> {
  WorkoutsCubit(this._repository) : super(const WorkoutsInitial());

  final WorkoutRepository _repository;
  final _storage = WorkoutLocalStorage();
  final List<Workout> _workouts = [];

  Future<void> loadWorkouts() async {
    emit(const WorkoutsLoading());
    try {
      final remote = await _repository.getWorkouts();
      _workouts
        ..clear()
        ..addAll(remote);
      await _storage.save(_workouts); // keep local cache in sync
      await _storage.markSeeded();
    } on DioException {
      // Network unavailable — fall back to local cache
      await _loadFromCache();
    } catch (_) {
      await _loadFromCache();
    }
    _workouts.sort((a, b) => b.date.compareTo(a.date));
    emit(WorkoutsLoaded(List.unmodifiable(_workouts)));
  }

  Future<void> saveWorkout(Workout workout) async {
    try {
      final saved = await _repository.createWorkout(workout);
      _workouts.add(saved);
    } on DioException {
      // Offline: save locally with the generated id
      _workouts.add(workout);
    }
    _workouts.sort((a, b) => b.date.compareTo(a.date));
    await _storage.save(_workouts);
    emit(WorkoutsLoaded(List.unmodifiable(_workouts)));
  }

  Future<void> deleteWorkout(String id) async {
    try {
      await _repository.deleteWorkout(id);
    } on DioException {
      // Proceed with local delete even if remote fails
    }
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

  // ── private ────────────────────────────────────────────────────────────────

  Future<void> _loadFromCache() async {
    if (await _storage.isFirstLaunch()) {
      _workouts.addAll(kMockWorkouts);
      await _storage.save(_workouts);
      await _storage.markSeeded();
    } else {
      _workouts.addAll(await _storage.load());
    }
  }
}
