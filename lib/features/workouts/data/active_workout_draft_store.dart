import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:strengthlabs/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs/features/workouts/presentation/cubit/active_workout_state.dart';

/// Persists the in-progress workout session so it survives an app kill.
///
/// Backed by `shared_preferences` for fast read/write at every mutation.
/// In the offline-first phase this responsibility moves to the Drift database,
/// at which point this store becomes a thin adapter over it.
class ActiveWorkoutDraftStore {
  ActiveWorkoutDraftStore({SharedPreferences? prefs}) : _injected = prefs;

  static const _key = 'active_workout_draft';
  final SharedPreferences? _injected;

  Future<SharedPreferences> get _prefs async =>
      _injected ?? await SharedPreferences.getInstance();

  /// True if [state] has user-meaningful content worth restoring on next
  /// launch. Empty initial sessions are skipped to avoid noisy "recover?"
  /// prompts on every app open.
  static bool hasMeaningfulContent(ActiveWorkoutState state) {
    if (state.exercises.isNotEmpty) return true;
    return state.name.trim() != 'Workout';
  }

  Future<void> save(ActiveWorkoutState state) async {
    final p = await _prefs;
    await p.setString(_key, jsonEncode(_encode(state)));
  }

  Future<ActiveWorkoutState?> read() async {
    final p = await _prefs;
    final raw = p.getString(_key);
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return _decode(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final p = await _prefs;
    await p.remove(_key);
  }

  Map<String, dynamic> _encode(ActiveWorkoutState s) => {
        'name': s.name,
        'start_time': s.startTime.toUtc().toIso8601String(),
        'is_finished': s.isFinished,
        'exercises': s.exercises
            .map((e) => {
                  'id': e.id,
                  'exercise': e.exercise.toJson(),
                  'target_reps': e.targetReps,
                  'sets': e.sets
                      .map((set) => {
                            'id': set.id,
                            'weight': set.weight,
                            'reps': set.reps,
                            'rpe': set.rpe,
                            'is_completed': set.isCompleted,
                          })
                      .toList(),
                })
            .toList(),
      };

  ActiveWorkoutState _decode(Map<String, dynamic> data) {
    final exercises = (data['exercises'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => ActiveExercise(
              id: e['id'] as String,
              exercise:
                  Exercise.fromJson((e['exercise'] as Map).cast<String, dynamic>()),
              targetReps: e['target_reps'] as String?,
              sets: (e['sets'] as List? ?? const [])
                  .whereType<Map>()
                  .map((s) => ActiveSet(
                        id: s['id'] as String,
                        weight: s['weight'] as String? ?? '',
                        reps: s['reps'] as String? ?? '',
                        rpe: (s['rpe'] as num?)?.toDouble(),
                        isCompleted: s['is_completed'] as bool? ?? false,
                      ))
                  .toList(),
            ))
        .toList();
    return ActiveWorkoutState(
      name: data['name'] as String? ?? 'Workout',
      startTime: DateTime.parse(data['start_time'] as String),
      exercises: exercises,
      isFinished: data['is_finished'] as bool? ?? false,
    );
  }
}
