import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strengthlabs/features/workouts/data/active_workout_draft_store.dart';
import 'package:strengthlabs/features/workouts/data/workout_repository.dart';
import 'package:strengthlabs/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs/features/workouts/domain/entities/workout.dart';
import 'package:strengthlabs/features/workouts/domain/entities/workout_set.dart';
import 'package:strengthlabs/features/workouts/presentation/cubit/active_workout_state.dart';

/// A single exercise slot within a template pre-populated from a routine.
class TemplateEntry {
  const TemplateEntry({
    required this.exercise,
    required this.sets,
    this.targetReps,
  });

  final Exercise exercise;
  final int sets;
  final String? targetReps;
}

class ActiveWorkoutTemplate {
  const ActiveWorkoutTemplate({required this.name, required this.entries});

  final String name;
  final List<TemplateEntry> entries;
}

class ActiveWorkoutCubit extends Cubit<ActiveWorkoutState> {
  ActiveWorkoutCubit(
    this._repository, {
    ActiveWorkoutDraftStore? draftStore,
  })  : _draftStore = draftStore ?? ActiveWorkoutDraftStore(),
        super(ActiveWorkoutState(
          name: 'Workout',
          startTime: DateTime.now(),
          exercises: const [],
        ));

  final WorkoutRepository _repository;
  final ActiveWorkoutDraftStore _draftStore;

  /// Serialised write chain — ensures rapid successive mutations persist in
  /// the order they happened. Without this, two near-simultaneous emits race
  /// and the older state can overwrite the newer one.
  Future<void> _saveQueue = Future<void>.value();

  int _idCounter = 0;
  String _nextId() => '${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}';

  @override
  void emit(ActiveWorkoutState state) {
    super.emit(state);
    if (!state.isFinished &&
        ActiveWorkoutDraftStore.hasMeaningfulContent(state)) {
      _saveQueue = _saveQueue.then((_) => _draftStore.save(state));
    }
  }

  /// Flush any pending persistence — useful for tests and for moments when we
  /// want to guarantee disk consistency (e.g. before navigation away).
  Future<void> flushDraft() => _saveQueue;

  /// Hydrate from a previously-persisted draft. Returns true if a draft was
  /// found and applied (caller can then prompt the user to keep/discard).
  Future<bool> restoreDraft() async {
    final draft = await _draftStore.read();
    if (draft == null) return false;
    if (!ActiveWorkoutDraftStore.hasMeaningfulContent(draft)) {
      await _draftStore.clear();
      return false;
    }
    super.emit(draft);
    return true;
  }

  /// Drop any persisted draft and reset to an empty session. Used when the
  /// user explicitly chooses not to resume the previous draft.
  Future<void> discardDraft() async {
    await _draftStore.clear();
    super.emit(ActiveWorkoutState(
      name: 'Workout',
      startTime: DateTime.now(),
      exercises: const [],
    ));
  }

  void setName(String name) => emit(state.copyWith(name: name));

  void loadTemplate(ActiveWorkoutTemplate template) {
    final exercises = template.entries.map((e) {
      final setCount = e.sets.clamp(1, 20);
      return ActiveExercise(
        id: _nextId(),
        exercise: e.exercise,
        targetReps: e.targetReps,
        sets: List.generate(setCount, (_) => ActiveSet(id: _nextId())),
      );
    }).toList();
    emit(state.copyWith(name: template.name, exercises: exercises));
  }

  void addExercise(Exercise exercise) {
    final newExerciseId = _nextId();
    final newSetId = _nextId();
    final newExercise = ActiveExercise(
      id: newExerciseId,
      exercise: exercise,
      sets: [ActiveSet(id: newSetId)],
    );
    emit(state.copyWith(exercises: [...state.exercises, newExercise]));
    _prefillLastSet(exercise.id, newExerciseId, newSetId);
  }

  Future<void> _prefillLastSet(
      String exerciseCatalogId, String activeExerciseId, String activeSetId) async {
    try {
      final last = await _repository.getLastSet(exerciseCatalogId);
      if (last == null) return;

      final exercise = state.exercises.firstWhere(
        (e) => e.id == activeExerciseId,
        orElse: () => ActiveExercise(
            id: '',
            exercise: const Exercise(
              id: '',
              name: '',
              muscleGroup: MuscleGroup.core,
            ),
            sets: const []),
      );
      if (exercise.id.isEmpty) return;
      final set = exercise.sets.firstWhere(
        (s) => s.id == activeSetId,
        orElse: () => ActiveSet(id: ''),
      );
      if (set.id.isEmpty) return;
      if (set.weight.isNotEmpty || set.reps.isNotEmpty) return;

      updateSet(
        activeExerciseId,
        activeSetId,
        weight: last.weight?.toString() ?? '',
        reps: last.reps?.toString() ?? '',
        rpe: last.rpe,
      );
    } catch (_) {
      // Silent: prefill is a nice-to-have, not a required signal
    }
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
        return e.copyWith(
            sets: updated.isEmpty ? [ActiveSet(id: _nextId())] : updated);
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

    final finished = state.copyWith(isFinished: true);
    super.emit(finished);
    // No need to keep the draft after a successful finish.
    _draftStore.clear();

    return Workout(
      id: _nextId(),
      name: state.name,
      date: state.startTime,
      duration: now.difference(state.startTime),
      exercises: workoutExercises,
    );
  }
}
