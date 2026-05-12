import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strengthlabs/features/workouts/data/active_workout_draft_store.dart';
import 'package:strengthlabs/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs/features/workouts/presentation/cubit/active_workout_state.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('returns null when no draft exists', () async {
    final store = ActiveWorkoutDraftStore();
    expect(await store.read(), isNull);
  });

  test('persists a state and reads it back identical', () async {
    final store = ActiveWorkoutDraftStore();
    final state = ActiveWorkoutState(
      name: 'Push Day',
      startTime: DateTime.utc(2026, 5, 12, 10),
      exercises: [
        ActiveExercise(
          id: 'ae-1',
          exercise: const Exercise(
            id: 'e1',
            name: 'Bench Press',
            muscleGroup: MuscleGroup.chest,
          ),
          targetReps: '5x5',
          sets: const [
            ActiveSet(id: 's1', weight: '60', reps: '5', rpe: 7, isCompleted: true),
            ActiveSet(id: 's2', weight: '65', reps: '5'),
          ],
        ),
      ],
    );

    await store.save(state);
    final restored = await store.read();

    expect(restored, isNotNull);
    expect(restored!.name, state.name);
    expect(restored.startTime, state.startTime);
    expect(restored.exercises.length, 1);
    expect(restored.exercises.first.exercise.name, 'Bench Press');
    expect(restored.exercises.first.sets.first.weight, '60');
    expect(restored.exercises.first.sets.first.isCompleted, true);
    expect(restored.exercises.first.sets[1].isCompleted, false);
    expect(restored.exercises.first.targetReps, '5x5');
  });

  test('clear removes the draft', () async {
    final store = ActiveWorkoutDraftStore();
    await store.save(ActiveWorkoutState(
      name: 'x',
      startTime: DateTime.utc(2026, 5, 12),
      exercises: const [],
    ));
    expect(await store.read(), isNotNull);
    await store.clear();
    expect(await store.read(), isNull);
  });

  test('skips obviously empty drafts (no exercises, no name change)', () async {
    // An empty initial state shouldn't be considered a recoverable draft.
    expect(ActiveWorkoutDraftStore.hasMeaningfulContent(ActiveWorkoutState(
      name: 'Workout',
      startTime: DateTime.now(),
      exercises: const [],
    )), false);
    // But a renamed empty session counts.
    expect(ActiveWorkoutDraftStore.hasMeaningfulContent(ActiveWorkoutState(
      name: 'Leg Day',
      startTime: DateTime.now(),
      exercises: const [],
    )), true);
    // And any exercise counts.
    expect(ActiveWorkoutDraftStore.hasMeaningfulContent(ActiveWorkoutState(
      name: 'Workout',
      startTime: DateTime.now(),
      exercises: [
        ActiveExercise(
          id: 'a',
          exercise: const Exercise(
            id: 'e', name: 'n', muscleGroup: MuscleGroup.chest),
          sets: const [ActiveSet(id: 's')],
        ),
      ],
    )), true);
  });

  test('returns null on corrupt payload without crashing', () async {
    SharedPreferences.setMockInitialValues({
      'active_workout_draft': '{not valid json',
    });
    final store = ActiveWorkoutDraftStore();
    expect(await store.read(), isNull);
  });
}
