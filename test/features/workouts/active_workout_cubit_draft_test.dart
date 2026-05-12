import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strengthlabs/features/workouts/data/active_workout_draft_store.dart';
import 'package:strengthlabs/features/workouts/data/workout_repository.dart';
import 'package:strengthlabs/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs/features/workouts/presentation/cubit/active_workout_cubit.dart';

class _MockRepo extends Mock implements WorkoutRepository {}

void main() {
  late _MockRepo repo;

  const exercise = Exercise(
    id: 'e1',
    name: 'Squat',
    muscleGroup: MuscleGroup.legs,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = _MockRepo();
    when(() => repo.getLastSet(any())).thenAnswer((_) async => null);
  });

  test('persists state to draft store after a mutation', () async {
    final store = ActiveWorkoutDraftStore();
    final cubit = ActiveWorkoutCubit(repo, draftStore: store);

    cubit.setName('Leg Day');
    cubit.addExercise(exercise);
    await cubit.flushDraft();

    final draft = await store.read();
    expect(draft, isNotNull);
    expect(draft!.name, 'Leg Day');
    expect(draft.exercises.length, 1);
    expect(draft.exercises.first.exercise.id, 'e1');

    await cubit.close();
  });

  test('restoreDraft loads state from store and emits it', () async {
    final store = ActiveWorkoutDraftStore();
    final priorCubit = ActiveWorkoutCubit(repo, draftStore: store);
    priorCubit.setName('Pull Day');
    priorCubit.addExercise(exercise);
    await priorCubit.flushDraft();
    await priorCubit.close();

    final newCubit = ActiveWorkoutCubit(repo, draftStore: store);
    final restored = await newCubit.restoreDraft();
    expect(restored, true);
    expect(newCubit.state.name, 'Pull Day');
    expect(newCubit.state.exercises.length, 1);

    await newCubit.close();
  });

  test('restoreDraft returns false when there is no draft', () async {
    final cubit = ActiveWorkoutCubit(repo, draftStore: ActiveWorkoutDraftStore());
    expect(await cubit.restoreDraft(), false);
    await cubit.close();
  });

  test('finish clears the draft', () async {
    final store = ActiveWorkoutDraftStore();
    final cubit = ActiveWorkoutCubit(repo, draftStore: store);
    cubit.addExercise(exercise);
    await cubit.flushDraft();
    expect(await store.read(), isNotNull);

    cubit.finish();
    await cubit.flushDraft();

    expect(await store.read(), isNull);
    await cubit.close();
  });

  test('discardDraft clears persisted state and resets cubit', () async {
    final store = ActiveWorkoutDraftStore();
    final cubit = ActiveWorkoutCubit(repo, draftStore: store);
    cubit.setName('Will be discarded');
    cubit.addExercise(exercise);
    await cubit.flushDraft();

    await cubit.discardDraft();

    expect(await store.read(), isNull);
    expect(cubit.state.exercises, isEmpty);
    expect(cubit.state.name, 'Workout');
    await cubit.close();
  });

  test('serialises rapid emits — last state wins on disk', () async {
    final store = ActiveWorkoutDraftStore();
    final cubit = ActiveWorkoutCubit(repo, draftStore: store);
    for (var i = 0; i < 10; i++) {
      cubit.setName('Name $i');
    }
    await cubit.flushDraft();
    final draft = await store.read();
    expect(draft!.name, 'Name 9');
    await cubit.close();
  });
}
