import 'package:flutter_test/flutter_test.dart';
import 'package:strengthlabs/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs/features/workouts/domain/entities/workout.dart';
import 'package:strengthlabs/features/workouts/domain/entities/workout_set.dart';

void main() {
  group('Workout.fromJson (backend snake_case payload)', () {
    final backendPayload = <String, dynamic>{
      'id': '11111111-1111-1111-1111-111111111111',
      'name': 'Push Day',
      'date': '2026-05-12T18:00:00Z',
      'duration_seconds': 3600,
      'notes': 'felt strong',
      'exercises': [
        {
          'exercise': {
            'id': '22222222-2222-2222-2222-222222222222',
            'name': 'Bench Press',
            'muscle_group': 'chest',
            'is_custom': false,
          },
          'sets': [
            {
              'id': '33333333-3333-3333-3333-333333333333',
              'weight': 60.0,
              'reps': 10,
              'rpe': 7.5,
            },
          ],
        },
      ],
    };

    test('parses duration_seconds correctly (not zero)', () {
      final workout = Workout.fromJson(backendPayload);
      expect(workout.duration, const Duration(seconds: 3600));
    });

    test('parses muscle_group snake_case', () {
      final workout = Workout.fromJson(backendPayload);
      expect(workout.exercises.first.exercise.muscleGroup, MuscleGroup.chest);
    });

    test('parses is_custom snake_case', () {
      final workout = Workout.fromJson(backendPayload);
      expect(workout.exercises.first.exercise.isCustom, false);
    });

    test('parses set fields and defaults isCompleted to true', () {
      final workout = Workout.fromJson(backendPayload);
      final set = workout.exercises.first.sets.first;
      expect(set.weight, 60.0);
      expect(set.reps, 10);
      expect(set.rpe, 7.5);
      expect(set.isCompleted, true);
    });

    test('roundtrip toJson→fromJson preserves data and uses snake_case', () {
      final workout = Workout.fromJson(backendPayload);
      final encoded = workout.toJson();
      expect(encoded['duration_seconds'], 3600);
      expect(encoded.containsKey('durationSeconds'), false);
      final decoded = Workout.fromJson(encoded);
      expect(decoded.duration, workout.duration);
      expect(decoded.exercises.first.exercise.muscleGroup,
          workout.exercises.first.exercise.muscleGroup);
    });

    test('workout.toJson serializes date in UTC ISO-8601', () {
      // Local-time date — toJson must coerce to UTC to avoid off-by-one in weekly aggregates.
      final workout = Workout(
        id: 'w1',
        name: 'n',
        date: DateTime(2026, 5, 12, 23, 30), // local time
        duration: const Duration(seconds: 60),
        exercises: const [],
      );
      final encoded = workout.toJson();
      final dateStr = encoded['date'] as String;
      expect(dateStr.endsWith('Z'), true,
          reason: 'serialized date must be UTC (end with Z)');
    });
  });

  group('Exercise.fromJson', () {
    test('reads muscle_group and is_custom snake_case', () {
      final exercise = Exercise.fromJson({
        'id': 'e1',
        'name': 'Squat',
        'muscle_group': 'legs',
        'is_custom': true,
      });
      expect(exercise.muscleGroup, MuscleGroup.legs);
      expect(exercise.isCustom, true);
    });

    test('writes muscle_group and is_custom snake_case in toJson', () {
      const exercise = Exercise(
        id: 'e1',
        name: 'Squat',
        muscleGroup: MuscleGroup.legs,
        isCustom: true,
      );
      final json = exercise.toJson();
      expect(json['muscle_group'], 'legs');
      expect(json['is_custom'], true);
      expect(json.containsKey('muscleGroup'), false);
      expect(json.containsKey('isCustom'), false);
    });

    test('parses extended backend muscle groups (biceps, glutes, etc.)', () {
      for (final raw in const [
        'biceps',
        'triceps',
        'forearms',
        'glutes',
        'calves',
        'cardio',
        'other',
      ]) {
        final exercise = Exercise.fromJson({
          'id': 'e',
          'name': 'n',
          'muscle_group': raw,
          'is_custom': false,
        });
        // muscleGroup must round-trip the exact backend string.
        expect(exercise.muscleGroup.serverName, raw,
            reason: 'expected serverName=$raw for parsed "$raw"');
      }
    });
  });

  group('WorkoutSet.fromJson (no is_completed from server)', () {
    test('defaults isCompleted to true when key absent', () {
      final set = WorkoutSet.fromJson({
        'id': 's1',
        'weight': 50.0,
        'reps': 8,
        'rpe': null,
      });
      expect(set.isCompleted, true);
    });

    test('does not send isCompleted/is_completed to backend', () {
      const set = WorkoutSet(
        id: 's1',
        weight: 50,
        reps: 8,
      );
      final json = set.toJson();
      expect(json.containsKey('isCompleted'), false);
      expect(json.containsKey('is_completed'), false);
    });
  });
}
