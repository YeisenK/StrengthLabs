import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:strengthlabs/features/workouts/data/workout_repository.dart';
import 'package:strengthlabs/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs/features/workouts/domain/entities/workout.dart';
import 'package:strengthlabs/features/workouts/domain/entities/workout_set.dart';
import 'package:strengthlabs/features/workouts/presentation/cubit/workouts_cubit.dart';
import 'package:strengthlabs/features/workouts/presentation/cubit/workouts_state.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

class FakeWorkout extends Fake implements Workout {}

void main() {
  late MockWorkoutRepository repository;

  final exerciseSquat = Exercise(
    id: 'ex-1',
    name: 'Squat',
    muscleGroup: MuscleGroup.legs,
  );

  Workout workout(String id, String name, DateTime date) => Workout(
        id: id,
        name: name,
        date: date,
        duration: const Duration(minutes: 45),
        exercises: [
          WorkoutExercise(
            exercise: exerciseSquat,
            sets: const [WorkoutSet(id: 's-1', weight: 80, reps: 5, rpe: 8)],
          ),
        ],
      );

  setUpAll(() {
    registerFallbackValue(FakeWorkout());
  });

  setUp(() {
    repository = MockWorkoutRepository();
  });

  group('WorkoutsCubit.loadWorkouts', () {
    blocTest<WorkoutsCubit, WorkoutsState>(
      'emits [Loading, Loaded] sorted by date desc',
      build: () {
        when(() => repository.getWorkouts()).thenAnswer((_) async => [
              workout('a', 'Old', DateTime(2026, 5, 1)),
              workout('b', 'Recent', DateTime(2026, 5, 9)),
            ]);
        when(() => repository.getExercises())
            .thenAnswer((_) async => [exerciseSquat]);
        return WorkoutsCubit(repository);
      },
      act: (cubit) => cubit.loadWorkouts(),
      expect: () => [
        const WorkoutsLoading(),
        isA<WorkoutsLoaded>().having(
          (s) => s.workouts.map((w) => w.id).toList(),
          'order',
          ['b', 'a'],
        ),
      ],
    );

    blocTest<WorkoutsCubit, WorkoutsState>(
      'emits [Loading, Error] when repository throws',
      build: () {
        when(() => repository.getWorkouts())
            .thenThrow(Exception('Network down'));
        when(() => repository.getExercises())
            .thenThrow(Exception('Network down'));
        return WorkoutsCubit(repository);
      },
      act: (cubit) => cubit.loadWorkouts(),
      expect: () => [
        const WorkoutsLoading(),
        isA<WorkoutsError>(),
      ],
    );
  });

  group('WorkoutsCubit.saveWorkout', () {
    blocTest<WorkoutsCubit, WorkoutsState>(
      'inserts new workout at start of loaded list',
      build: () {
        final existing = workout('a', 'Existing', DateTime(2026, 5, 1));
        final newWorkout = workout('b', 'New', DateTime(2026, 5, 9));
        when(() => repository.getWorkouts())
            .thenAnswer((_) async => [existing]);
        when(() => repository.getExercises())
            .thenAnswer((_) async => [exerciseSquat]);
        when(() => repository.createWorkout(any()))
            .thenAnswer((_) async => newWorkout);
        return WorkoutsCubit(repository);
      },
      act: (cubit) async {
        await cubit.loadWorkouts();
        await cubit.saveWorkout(workout('b', 'New', DateTime(2026, 5, 9)));
      },
      skip: 2,
      expect: () => [
        isA<WorkoutsLoaded>().having(
          (s) => s.workouts.map((w) => w.id).toList(),
          'order',
          ['b', 'a'],
        ),
      ],
    );

    blocTest<WorkoutsCubit, WorkoutsState>(
      'rethrows and keeps loaded state on failure',
      build: () {
        when(() => repository.getWorkouts()).thenAnswer((_) async => []);
        when(() => repository.getExercises())
            .thenAnswer((_) async => [exerciseSquat]);
        when(() => repository.createWorkout(any()))
            .thenThrow(Exception('Save failed'));
        return WorkoutsCubit(repository);
      },
      act: (cubit) async {
        await cubit.loadWorkouts();
        try {
          await cubit.saveWorkout(workout('b', 'New', DateTime.now()));
        } catch (_) {}
      },
      verify: (cubit) {
        expect(cubit.state, isA<WorkoutsLoaded>());
        expect((cubit.state as WorkoutsLoaded).workouts, isEmpty);
      },
    );
  });

  group('WorkoutsCubit.deleteWorkout', () {
    blocTest<WorkoutsCubit, WorkoutsState>(
      'removes the workout from loaded list',
      build: () {
        when(() => repository.getWorkouts()).thenAnswer((_) async => [
              workout('a', 'A', DateTime(2026, 5, 1)),
              workout('b', 'B', DateTime(2026, 5, 2)),
            ]);
        when(() => repository.getExercises())
            .thenAnswer((_) async => [exerciseSquat]);
        when(() => repository.deleteWorkout('a')).thenAnswer((_) async {});
        return WorkoutsCubit(repository);
      },
      act: (cubit) async {
        await cubit.loadWorkouts();
        await cubit.deleteWorkout('a');
      },
      skip: 2,
      expect: () => [
        isA<WorkoutsLoaded>().having(
          (s) => s.workouts.map((w) => w.id).toList(),
          'remaining',
          ['b'],
        ),
      ],
    );
  });

  group('WorkoutsCubit.findById', () {
    test('returns workout when present in loaded state', () async {
      when(() => repository.getWorkouts()).thenAnswer((_) async => [
            workout('a', 'A', DateTime(2026, 5, 1)),
          ]);
      when(() => repository.getExercises())
          .thenAnswer((_) async => [exerciseSquat]);

      final cubit = WorkoutsCubit(repository);
      await cubit.loadWorkouts();

      expect(cubit.findById('a')?.name, 'A');
      expect(cubit.findById('missing'), isNull);
    });

    test('returns null when state is not Loaded', () {
      final cubit = WorkoutsCubit(repository);
      expect(cubit.findById('any'), isNull);
    });
  });
}
